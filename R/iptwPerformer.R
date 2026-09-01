# solve based on how formula is pointed out
.resolveTreatmentModel = function(options) {
  hasCustom = !is.null(options$customFormula$model) &&
    nchar(trimws(options$customFormula$model)) > 0

  if (hasCustom) {
    f = tryCatch(as.formula(options$customFormula$model), error = function(e) e)
    if (inherits(f, "error")) {
      return(list(error = gettextf("Could not parse the custom formula: %s", f$message)))
    }
    treatment  = all.vars(f[[2]])                       # LHS variable name
    covariates = all.vars(delete.response(terms(f)))    # RHS variable names, stripped of ns()/I()/etc.
  } else {
    treatment  = options$treatment
    covariates = options$confounders
    f = as.formula(paste0(treatment, "~", paste(covariates, collapse = " + ")))
  }

  list(formula = f, treatment = treatment, covariates = covariates, error = NULL)
}
# density of weights plot
.createIptwDensities=function(jaspResults, dataw, options) {
  model = .resolveTreatmentModel(options)
  if (!is.null(model$error)) { jaspResults$setError(model$error); return() }
  treatment = model$treatment
  # add treatment column to dataset with factor format
  dataw$treatment_label=factor(dataw[[treatment]],
                               levels = c(0, 1),
                               labels = c("Untreated", "Treated"))
  # plot weights by treatment
  p=ggplot2::ggplot(dataw, aes(x = weight, fill = treatment_label, color = treatment_label))+
    ggplot2::geom_density(alpha=options$opacity)+
    ggplot2::scale_fill_manual(values = c(options$untreatedColor, options$treatedColor),
                              labels = c("Untreated", "Treated")) +
    ggplot2::scale_color_manual(values = c(options$untreatedColor, options$treatedColor),
                               labels = c("Untreated", "Treated")) +
    ggplot2::labs(x = "Weights", y = "Density", fill = "Treatment") +
    ggplot2::guides(col='none')+
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = "bottom")
  # create JASP plot
  weightPlot=createJaspPlot(title = "Weight Densities", width = 400, height = 300)
  weightPlot$dependOn(c("treatment", "confounders", "stabilize", "truncateEnabled", "customFormula",
                        "opacity", "untreatedColor", "treatedColor"))
  weightPlot$plotObject=p
  jaspResults[["weightDensities"]]=weightPlot
}
# love plot
.createIptwLovePlot=function(jaspResults, dataset, options) {
  model = .resolveTreatmentModel(options)
  if (!is.null(model$error)) { jaspResults$setError(model$error); return() }
  treatment = model$treatment
  f = model$formula
  w = dataset$weight
  # calculate standardized means for both groups and plot with ggplot
  loveplot=cobalt::love.plot(data=dataset,
                             x=f,
                             weights=w,
                             binary="std",
                             un=TRUE,
                             s.d.denom="pooled")+
    ggplot2::theme_bw() +
    ggplot2::scale_color_manual(values = c(options$untreatedColor, options$treatedColor)) +
    ggplot2::geom_vline(xintercept = c(-0.1, 0.1), lty = 2, col = "black") +
    ggplot2::theme(legend.position = "bottom")
  # create JASP plot
  lovePlot=createJaspPlot(title = gettext("Love Plot"), width = 400, height = 400)
  lovePlot$dependOn(c("treatment", "confounders", "stabilize", "truncateEnabled","customFormula",
                      "truncate", "untreatedColor", "treatedColor"))
  lovePlot$plotObject=loveplot
  jaspResults[["iptwLovePlot"]]=lovePlot
}
# propensity score overlap plot
.createPSOverlapPlot=function(jaspResults, dataset, options) {
  model = .resolveTreatmentModel(options)
  if (!is.null(model$error)) { jaspResults$setError(model$error); return() }
  treatment = model$treatment
  f = model$formula
  # compute model
  ps_model=glm(f, data = dataset, family = binomial(link = "logit"))
  # predict propensity scores
  ps=predict(ps_model, type = "response")
  # create dataset to plot
  plotdf=data.frame(ps=ps,treatment=as.character(dataset[[treatment]]))
  # plot densities of ps for both groups
  p=ggplot2::ggplot(plotdf, aes(x=ps, fill=treatment, color = treatment)) +
    ggplot2::geom_density(alpha=options$opacity) +
    ggplot2::scale_fill_manual(values=c(options$untreatedColor, options$treatedColor),
                               labels=c("Untreated", "Treated"),
                               guide=ggplot2::guide_legend(nrow = 1, byrow = T)) +
    ggplot2::scale_color_manual(values=c(options$untreatedColor, options$treatedColor)) +
    ggplot2::guides(alpha="none",col='none') +
    ggplot2::labs(x="Propensity Score",
                  y="Density",
                  fill="Treatment") +
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position="bottom")
  # create JASP plot
  psPlot=createJaspPlot(title=gettext("Propensity Score Overlap"), width = 400, height = 300)
  psPlot$dependOn(c("treatment", "confounders", "customFormula","opacity", "untreatedColor", "treatedColor"))
  psPlot$plotObject=p
  jaspResults[["psOverlapPlot"]]=psPlot
}
# weight summary table
.createWeightSummaryTable=function(jaspResults, dataw, options) {
  model = .resolveTreatmentModel(options)
  if (!is.null(model$error)) { jaspResults$setError(model$error); return() }
  treatment = model$treatment
  f = model$formula
  w = dataw$weight
  treat_col=as.integer(as.character(dataw[[treatment]]))
  # compute summary by group
  groups=list(Treated = w[treat_col == 1], Untreated = w[treat_col == 0])
  # calculate quantities of interest
  ## this part may be done in a better way (?)
  rows=lapply(names(groups), function(g) {
    wg=groups[[g]]
    data.frame(Group=g,
               N=length(wg),
               Min=round(min(wg),3),
               Max=round(max(wg),3),
               Mean=round(mean(wg),3),
               Median=round(median(wg),3),
               SD=round(sd(wg),3))
  })
  df=do.call(rbind, rows)
  # create JASP table
  table=createJaspTable(title = gettext("Weight Summary"))
  table$dependOn(c("treatment", "confounders", "stabilize", "customFormula","truncateEnabled", "truncate"))
  table$addRows(df)
  jaspResults[["weightSummary"]]=table
}
# smd summary table
.createSMDTable=function(jaspResults, dataset, options) {
  # define columns needed
  model = .resolveTreatmentModel(options)
  if (!is.null(model$error)) { jaspResults$setError(model$error); return() }
  treatment = model$treatment
  f = model$formula
  w = dataset$weight
  # calculate quantities of interest
  bal=cobalt::bal.tab(x=f,
                      data=dataset,
                      weights=w,
                      un=T,
                      binary="std")
  # define dataset and table
  df=as.data.frame(bal$Balance)
  df$Covariate=rownames(df)
  df=df[, c("Covariate", "Diff.Un", "Diff.Adj")]
  colnames(df)=c("Covariate", "SMD Before", "SMD After")
  df[, 2:3]=round(df[, 2:3], 3)
  # create JASP table
  table=createJaspTable(title = gettext("Standardized Mean Differences"))
  table$dependOn(c("treatment", "confounders", "stabilize","customFormula", "truncateEnabled", "truncate"))
  table$addRows(df)
  jaspResults[["smdTable"]]=table
}
# effective sample size (ess) table
.createESSTable=function(jaspResults, dataset, options) {
  # define column needed
  model = .resolveTreatmentModel(options)
  if (!is.null(model$error)) { jaspResults$setError(model$error); return() }
  treatment = model$treatment
  f = model$formula
  w = dataset$weight
  treat_num=as.integer(as.character(dataset[[treatment]]))
  # calculate ess as ESS = (sum(w))^2 / sum(w^2)
  ess_trt=sum(w[treat_num == 1])^2 / sum(w[treat_num == 1]^2)
  ess_untrt=sum(w[treat_num == 0])^2 / sum(w[treat_num == 0]^2)
  n_trt=sum(treat_num == 1)
  n_untrt=sum(treat_num == 0)
  # define dataset
  df=data.frame(Group=c("Treated", "Untreated"),
                N=c(n_trt, n_untrt),
                ESS=c(round(ess_trt, 1), round(ess_untrt, 1)),
                "ESS/N (%)"=c(round(100 * ess_trt / n_trt, 1),
                              round(100 * ess_untrt / n_untrt, 1)),
                check.names=FALSE)
  # create JASP table
  table=createJaspTable(title = gettext("Effective Sample Size"))
  table$dependOn(c("treatment", "confounders", "stabilize","customFormula", "truncateEnabled", "truncate"))
  table$addRows(df)
  jaspResults[["essTable"]]=table
}
# weighting function
iptw=function(jaspResults, dataset, options) {
  model = .resolveTreatmentModel(options)
  if (!is.null(model$error)) { jaspResults$setError(model$error); return() }
  if (length(model$treatment) == 0) return()
  if (length(model$covariates) == 0) return()
  treatment = model$treatment
  f = model$formula
  # compute treatment model
  den_model=glm(f, data = dataset, family = binomial(link = "logit"))
  # predict propensity score
  ps=predict(den_model, type = "response")
  # get treatment column
  trt_col=dataset[[treatment]]
  # define weights
  w=ifelse(trt_col==1,
           1/ps,
           1/(1-ps))
  # compute stabilized weights, if asked to
  if (isTRUE(options$stabilize)) {
    trt_num=as.integer(as.character(trt_col))
    p_trt=mean(trt_num,na.rm=TRUE)
    w=ifelse(trt_num==1,
             p_trt/ps,
             (1-p_trt)/(1 - ps))
  }
  # truncate stabilized weights, if asked to
  if (isTRUE(options$truncateEnabled)) {
    lower=quantile(w,options$truncate)
    upper=quantile(w,1-options$truncate)
    w=pmin(pmax(w,lower),upper)
  }
  # add weights to dataset
  dataset$weight=w
  # run plots and table
  .createWeightSummaryTable(jaspResults, dataset, options)
  .createSMDTable(jaspResults, dataset, options)
  .createESSTable(jaspResults, dataset, options)
  .createIptwDensities(jaspResults, dataset, options)
  .createIptwLovePlot(jaspResults, dataset, options)
  .createPSOverlapPlot(jaspResults, dataset, options)
}
