
# Setup and run

library(icesTAF)

getwd()

setwd("C:/Users/kibi/OneDrive - Danmarks Tekniske Universitet/2026_all_RDBES_DK")

dat <- c()

for (i in c(2:16)) {
  
  dat_0 <- readxl::read_xlsx(paste0(".adm/boot/data/data_call/30939734/", "DC_Annex_1.xlsx"), sheet = c(i))
  
  dat <- rbind(dat, dat_0)
}

names(dat) <- gsub(" ", "", names(dat))

awgs <- unique(dat$ExpertGroup)

for (i in awgs) {
  
  mkdir(i)
  taf.skeleton(path = paste0("./", i))
  
  # Adding a utilities script
  file.create(paste0("./", i, "/", "utilities.R"))
  
  # Add folders for script
  folder_types <- c("data", "model", "output", "report", "utilities")
  
  for (j in folder_types) {
    mkdir(paste0("./", i, "/", j, "_scripts"))
  }
  
}

