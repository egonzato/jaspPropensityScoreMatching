.createSummaryTableBefore=function(jaspResults, matched, options) {
  summary=summary(matched)
  sumall=summary$sum.all
  # Prepare data
  df=as.data.frame(sumall)
  df$Covariate=rownames(sumall)
  df=df[, c("Covariate", colnames(sumall))]
  df=df[, -8]
  # Auto table from data.frame
  table=createJaspTable(title = gettext("Confounders balance before matching"))
  table$dependOn(c("method_dropdown", "treatment", "confounders",
                   "distance_dropdown","ratio", "replacement", "distance"))
  table$setExpectedSize(nrow(df), length(colnames(df)))
  # Add all data
  table$addRows(df)
  jaspResults[["balanceTableBefore"]]=table
}

.createSummaryTableAfter=function(jaspResults, matched, options) {
  summary=summary(matched)
  summatch=summary$sum.matched
  # Prepare data
  df=as.data.frame(summatch)
  df$Covariate=rownames(summatch)
  df=df[, c("Covariate", colnames(summatch))]
  # Auto table from data.frame
  table=createJaspTable(title = gettext("Confounders balance after matching"))
  table$dependOn(c("method_dropdown", "treatment", "confounders",
                 "distance_dropdown","ratio", "replacement", "distance"))
  table$setExpectedSize(nrow(df), length(colnames(df)))
  # Add all data
  table$addRows(df)
  jaspResults[["balanceTableAfter"]]=table
}


.createSampleSizeTable=function(jaspResults, matched, options) {
  summary=summary(matched)
  sumnn=summary$nn
  # Prepare data
  df=as.data.frame(sumnn)
  df$Sample=rownames(sumnn)
  df=df[, c("Sample", colnames(sumnn))]
  # Auto table from data.frame
  table=createJaspTable(title = gettext("Sample sizes"))
  table$dependOn(c("method_dropdown", "treatment", "confounders",
                   "distance_dropdown","ratio", "replacement", "distance"))
  table$setExpectedSize(nrow(df), length(colnames(df)))
  # Add all data
  table$addRows(df)
  jaspResults[["SampleSizes"]]=table
}

# love plot
.createLovePlot=function(jaspResults,matched,options){
  # plot
  loveplotmatched=cobalt::love.plot(matched)+
    ggplot2::theme_bw()+
    ggplot2::scale_color_manual(values = c(options$untreatedColor,options$treatedColor))+
    ggplot2::geom_vline(xintercept = c(-0.1,+0.1),lty=2,col='black')+
    ggplot2::theme(legend.position = 'bottom')
  # create jasp graph
  lovePlot=createJaspPlot(title = gettext("Love Plot"), width = 400, height = 500)
  lovePlot$dependOn(c("method_dropdown","treatment","confounders",
                         "distance_dropdown","ratio","replacement"))
  lovePlot$info=gettext("This figure displays a the standardized mean difference for all the confounders considered")
  jaspResults[["lovePlot"]]=lovePlot
  lovePlot$plotObject=loveplotmatched
}
# densities
.createDensities=function(jaspResults,dataset,matched,options){

  # helper to extract legend
  get_legend <- function(myggplot) {
    tmp <- ggplot2::ggplot_gtable(ggplot2::ggplot_build(myggplot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    tmp$grobs[[leg]]
  }

  # define covariates
  treat = as.character(matched$formula[[2]])
  covariates = attr(terms(matched$formula), "term.labels")

  # types
  covar_types = sapply(dataset[, covariates, drop = FALSE], function(x) {
    if (is.numeric(x)) "continuous" else "categorical"
  })

  # matched dataset
  matcheddf = match.data(matched)

  gglist = list()
  covs = rep(covariates,2)
  covs_type = rep(covar_types,2)

  # create plots
  for (p in 1:length(rep(covariates,2))) {

    if (p <= length(covariates)){
      df = dataset
    } else {
      df = matcheddf
    }



    if (covs_type[p] == 'continuous') {

      gglist[[p]] = ggplot2::ggplot(df,
                                    aes(x=.data[[covs[p]]],
                                        group=factor(.data[[treat]]),
                                        fill=factor(.data[[treat]])))+
        ggplot2::geom_density(alpha=options$opacity)+
        ggplot2::scale_fill_manual(values = c(options$untreatedColor,options$treatedColor),
                                   labels = c("Untreated", "Treated"),
                                   guide = ggplot2::guide_legend(nrow=1,byrow=T))+
        ggplot2::guides(alpha='none')+
        ggplot2::labs(fill="Treatment")+
        ggplot2::theme_bw()

    } else {

      gglist[[p]] = ggplot2::ggplot(df,
                                    aes(x=.data[[covs[p]]],
                                        group=factor(.data[[treat]]),
                                        fill=factor(.data[[treat]])))+
        ggplot2::geom_bar(position='dodge',col='black',alpha=options$opacity)+
        ggplot2::scale_fill_manual(values = c(options$untreatedColor,options$treatedColor),
                                   labels = c("Untreated", "Treated"),
                                   guide = ggplot2::guide_legend(nrow=1,byrow=T))+
        ggplot2::guides(alpha='none',col='none')+
        ggplot2::labs(fill="Treatment")+
        ggplot2::theme_bw()
    }
  }

  # extract legend from first plot
  legend = get_legend(gglist[[1]])

  # remove legends from all plots
  gglist = lapply(gglist, function(p) p + ggplot2::theme(legend.position="none"))

  # arrange columns
  col_unmatched = gridExtra::arrangeGrob(
    grobs = gglist[1:length(covariates)],
    ncol = 1,
    nrow = length(covar_types),
    top = paste("Original dataset (n=", dim(dataset)[1], ')', sep='')
  )

  col_matched = gridExtra::arrangeGrob(
    grobs = gglist[(length(covariates)+1):length(gglist)],
    ncol = 1,
    nrow = length(covar_types),
    top = paste("Matched dataset (n=", dim(matcheddf)[1], ')', sep='')
  )

  plots = gridExtra::arrangeGrob(col_unmatched, col_matched, ncol = 2)

  densityGrobs = gridExtra::arrangeGrob(
    plots,
    legend,
    ncol = 1,
    heights = c(10,1)
  )

  # create JASP plot
  densityPlot = createJaspPlot(title = gettext("Density Plot"), width = 400, height = 500)

  densityPlot$dependOn(c("method_dropdown","treatment","confounders",
    "distance_dropdown","ratio","replacement","opacity",
    "untreatedColor","treatedColor"))

  densityPlot$info = gettext("This figure displays the distribution of the covariates in treated and untreated groups.")

  jaspResults[["densityPlot"]] = densityPlot
  densityPlot$plotObject = densityGrobs
}
# matching performer
matching=function(jaspResults,dataset,options){
  # define formula
  f=as.formula(paste(options$treatment,'~',paste(options$confounders,collapse='+')))
  #redefine distance to matchit syntax
  distance_lower=dplyr::case_when(stringr::str_to_lower(options$distance_dropdown)=='probability'~'glm',
                                  stringr::str_to_lower(options$distance_dropdown)=='Logit'~'logit',
                                  T~'mahalanobis')
  # caliper
  if (isTRUE(options$caliperEnabled) && distance_lower %in% c("glm", "logit")) {
    caliper_null=options$caliper
  } else {
    caliper_null=NULL
  }
  # run matching
  matched=MatchIt::matchit(formula=f,
                           data=dataset,
                           caliper=caliper_null,
                           ratio=options$ratio,
                           replace=options$replacement,
                           distance=distance_lower,
                           method=str_to_lower(options$method_dropdown))
  #tables
  ## before
  .createSummaryTableBefore(jaspResults, matched, options)
  ## after
  .createSummaryTableAfter(jaspResults, matched, options)
  ## sample sizes
  .createSampleSizeTable(jaspResults, matched, options)
  # density
  .createDensities(jaspResults,dataset,matched,options)
  # love plot
  .createLovePlot(jaspResults,matched,options)
}

