library(Rserve)
library(pacman)
p_load(Rserve, RColorBrewer, xtable, som, fitdistrplus, ROCR, RJSONIO, gplots, e1071, caTools, igraph, randomForest, Cairo, pls, pheatmap, lattice, rmarkdown, knitr, data.table, pROC, Rcpp, caret, ellipse, scatterplot3d, impute, pcaMethods, siggenes, globaltest, GlobalAncova, Rgraphviz, KEGGgraph, preprocessCore, genefilter, SSPA, sva, limma, car)
Rserve(args=" --no-save --RS-conf /etc/rserve.conf")