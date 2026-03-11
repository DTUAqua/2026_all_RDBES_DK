
library(icesTAF)


# taf.skeleton()

# getwd()
# 
# setwd("./HAWG")
# 
# getwd()

# Boot  ----
# mkdir("boot/initial/data/template")

draft.data(data.files = "template",
           data.scripts = NULL,
           originator = "Data call and SC's",
           title = "Copy of HAWG templates",
           file = T,
           access = "Public",
           append = F)

# mkdir("boot/initial/data/template_submitted_last_year")

draft.data(data.files = "template_submitted_last_year",
           data.scripts = NULL,
           originator = "DTU Aqua",
           title = "Template with DNK data submitted last year",
           file = T,
           access = "Restricted",
           append = T)


draft.data(data.files = NULL,
           data.scripts = "fl_area_relation",
           originator = "FishLine",
           title = "Area relation from FishLine",
           access = "Restricted",
           file = T,
           append = T)

taf.boot()

# mkdir("data")
# mkdir("data_scripts")
# mkdir("model/WKSAND16")


