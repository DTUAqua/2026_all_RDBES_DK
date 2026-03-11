

library(dplyr)
library(lubridate)

options(scipen = 999)

#Landings

years <- c(2024:2026)
spr_dfad <- c()

for (i in years) {
  
  
  dfad_0 <- readRDS(paste("Q:/20-forskning/20-dfad/data/Data/udvidet_data/dfad_udvidet", i, ".rds", sep = ""))
  names(dfad_0) <- tolower(names(dfad_0))
  dfad_0$hel[is.na(dfad_0$hel)] <- 0
  
  dfad_0 <- mutate(dfad_0, year = year(ldato), quarter = quarter(ldato), month = month(ldato), ctry = "DK")
  
  dfad_1 <- filter(dfad_0, art == "BRS")
  
  dfad_sum <- summarise(group_by(dfad_1, ctry, year, quarter, art, fao_area, dfadfvd_ret, square_ret), kg = sum(hel, na.rm = T))
  
  spr_dfad <- bind_rows(spr_dfad, dfad_sum)
  
}

save(spr_dfad, file = "data/spr.27.3a4/spr_dfad.Rdata")
