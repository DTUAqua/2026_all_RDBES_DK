
library(icesTAF)


# taf.skeleton()

# getwd()
# 
# setwd("./WGBFAS") - WD needs to be in AWG folder
# 
# getwd()

# Boot  ----

draft.data(data.files = "data_call",
           data.scripts = NULL,
           originator = "Data call and tamplates",
           title = "ICES data call with templates",
           file = T,
           access = "Public",
           append = F)

draft.data(data.files = "fleet_relation",
           data.scripts = NULL,
           originator = "DTU Aqua",
           title = "Fleet relation", 
           source = "Q:/50-radgivning/02-mynd/SAS Library/fleet",
           file = T,
           access = "Public",
           append = T)

draft.data(data.files = "official_lan_bms_from_fst",
           data.scripts = NULL,
           originator = "LFST",
           title = "Copy of of official landings and BMS sent to ICES by LFST",
           file = T,
           access = "Restricted",
           append = T)



taf.boot()

# mkdir("data")
# mkdir("data_scripts")
# mkdir("model/WKSAND16")


