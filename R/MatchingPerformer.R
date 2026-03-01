# love plot
.createLovePlot=function(jaspResults,matched){
  # plot
  loveplotmatched=cobalt::love.plot(matched)+
    ggplot2::theme_bw()+
    ggplot2::scale_color_manual(values = c('#FF3300',"#0099FF"))+
    ggplot2::geom_vline(xintercept = c(-0.1,+0.1),lty=2,col='black')+
    ggplot2::theme(legend.position = 'bottom')
  # create jasp graph
  lovePlot=createJaspPlot(title = gettext("Love Plot"), width = 300, height = 400)
  lovePlot$dependOn(c("method_dropdown", "treatment", "confounders","distance_dropdown","ratio","replacement")) # Refresh view whenever a changes
  lovePlot$info=gettext("This figure displays a the standardized mean difference for all the confounders considered")
  jaspResults[["lovePlot"]]=lovePlot
  lovePlot$plotObject=loveplotmatched
}
# densities
.createDensities=function(jaspResults,dataset,matched){
  # define covariates
  treat=as.character(matched$formula[[2]])
  covariates=attr(terms(matched$formula), "term.labels")
  ## types
  covar_types=sapply(dataset[, covariates, drop = FALSE], function(x) {
    if (is.numeric(x)) {"continuous"}
    else {"categorical"}})
  # define dataset
  matcheddf=match.data(matched)
  # define list
  gglist=list()
  # plot each one
  for (p in 1:length(rep(covariates,2))) {
    # plot for both treated and untreated
    if (p<=length(covariates)){
      df=dataset
    } else {
      df=matcheddf
    }
    #
    covs=rep(covariates,2); covs_type=rep(covar_types,2)
    #
    if (covs_type[p]=='continuous'){
      gglist[[p]]=ggplot2::ggplot(df,aes(x=.data[[covs[p]]],
                                group=factor(.data[[treat]]),
                                fill=factor(.data[[treat]]),
                                alpha=0.3))+
        ggplot2::geom_density()+
        ggplot2::guides(alpha='none',fill='none')+
        ggplot2::scale_fill_manual(values = c('#FF3300',"#0099FF")) +
        #ggplot2::labs(fill='Treatment')+
        ggplot2::theme_bw()
    } else {
      gglist[[p]]=ggplot2::ggplot(df,aes(x=.data[[covs[p]]],
                                group=factor(.data[[treat]]),
                                fill=factor(.data[[treat]]),
                                alpha=0.3))+
        ggplot2::geom_bar(position='dodge',col='black')+
        ggplot2::guides(alpha='none',col='none',fill='none')+
        ggplot2::scale_fill_manual(values = c('#FF3300',"#0099FF")) +
        #ggplot2::labs(fill='Treatment')+
        ggplot2::theme_bw()
    }
  }
  # create plots
  col_unmatched=gridExtra::arrangeGrob(grobs = gglist[1:length(covariates)], ncol = 1, nrow = length(covar_types), top = paste("Original dataset (n=",dim(dataset)[1],')',sep=''))
  col_matched=gridExtra::arrangeGrob(grobs = gglist[(length(covariates)+1):length(gglist)], ncol = 1, nrow = length(covar_types), top = paste("Matched dataset (n=",dim(matcheddf)[1],')',sep=''))
  densityGrobs=gridExtra::grid.arrange(col_unmatched, col_matched, ncol = 2)
  # create Jasp object
  densityPlot=createJaspPlot(title = gettext("Density Plot"), width = 300, height = 400)
  densityPlot$dependOn(c("method_dropdown", "treatment", "confounders","distance_dropdown", "ratio","replacement"))
  densityPlot$info=gettext("This figure displays the distribution of the covariates in treated and untreated groups.")
  jaspResults[["densityPlot"]]=densityPlot
  densityPlot$plotObject=densityGrobs

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
  # density
  .createDensities(jaspResults,dataset,matched)
  # love plot
  .createLovePlot(jaspResults,matched)}

