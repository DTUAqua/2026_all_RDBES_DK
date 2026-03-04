
# Setup and run

library(icesTAF)

# library(remotes)
# install_github("ices-tools-dev/RDBEScore", build_vignettes = TRUE

getwd()
# setwd("./kibi_one_repo")
# getwd()

# Create AWG folders
## Based on a file created from Annex 1, where DK | 'All countries' is mentioned

annex_1 <- openxlsx::read.xlsx(
  "Q:/mynd/Assessement_discard_and_the_like/national_AWG_BM_submissions/adm/2024/ices_big_data_call_annex_1_overview_2024_2024-03-05.xlsx"
)

awgs <- unique(annex_1$Expert.Group)

for (i in awgs) {
  
  mkdir(i)
  icesTAF::taf.skeleton(path = paste0("./", i))
  
  # Adding a utilities script
  file.create(paste0("./", i, "/", "utilities.R"))
  
  # Add folders for script
  folder_types <- c("data", "model", "output", "report", "utilities")
  
  for (j in folder_types) {
    mkdir(paste0("./", i, "/", j, "_scripts"))
  }
 
}

# setwd("./AFWG")
getwd()
icesTAF::draft.data()

draft.data(
  data.files = "data_from_rdbes",
  data.scripts = NULL,
  originator = "HAWG",
  year = "2025",
  title = "Data from the RDBES summed",
  access     = "Restricted",
  file = T,
  append = F
)

icesTAF::taf.boot()
