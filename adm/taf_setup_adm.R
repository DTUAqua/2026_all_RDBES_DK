
library(icesTAF)


# taf.skeleton()

getwd()

setwd("./adm")

taf.skeleton()

getwd()

mkdir("boot/initial/data/data_call")


draft.data(data.files = "data_call",
           data.scripts = NULL,
           originator = "ICES",
           title = "ICES big data call, version 02022026",
           file = T,
           append = F)

taf.boot()
