## Extract results of interest, write TAF output tables

## Before:
## After:

library(icesTAF)
library(openxlsx)

getwd()

mkdir("output")

load("model/spr.27.3a4_alk_per_sample.Rdata")
load("model/spr.27.3a4_lan_ld_per_sample.Rdata")
load("model/spr.27.3a4_no_samples.Rdata")
load("model/spr.27.3a4_lan_per_yq_area.Rdata")
load("model/spr.27.3a4_lan_per_yq_rect.Rdata")

# The workbook needs to be .xlsx and isUnzipped = F
wb <- openxlsx::loadWorkbook("./boot/data/data_call/30939734/DC_Annex_HAWG2 spr.27.3a4 template.xlsx", 
                             isUnzipped = F)

writeData(wb, sheet = "CATCHES_(Sub)Div",spr.27.3a4_lan_per_yq_area, colNames = F, startRow = 2)
writeData(wb, sheet = "CATCHES_StatRec", spr.27.3a4_lan_per_yq_rect, colNames = F, startRow = 2)
writeData(wb, sheet = "BIO_samples_ALK data", spr27.3a4_alk_per_sample, colNames = F, startRow = 2)
writeData(wb, sheet = "BIO_samples_LengthFreq", spr.27.3a4_lan_ld_per_sample, colNames = F, startRow = 2)
writeData(wb, sheet = "SAMPLING", spr.27.3a4_no_samples, colNames = F, startRow = 2)

saveWorkbook(wb,"output/DC_Annex_HAWG2 spr.27.3a4 template_DNK_2023_2025.xlsx", overwrite = T)
