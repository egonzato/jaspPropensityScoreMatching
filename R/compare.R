# libraries
pacman::p_load(dplyr,MatchIt)
# comparison
df=read.csv("C:\\Users\\P095206\\OneDrive - Amsterdam UMC\\Shared material with Elia\\PhD\\Presentations\\Confounding\\example.csv")
# perform matching
match=matchit(trt~age+sex+chol,
              data=df,
              method='nearest',
              distance='mahalanobis',
              ratio=2,
              replace=F)
# summary
summary(match)
#
summary=summary(match)
sumall=summary$nn
# Prepare data
df=as.data.frame(sumall)
df$Sample=rownames(sumall)
df=df[, c("Sample", colnames(sumall))]
