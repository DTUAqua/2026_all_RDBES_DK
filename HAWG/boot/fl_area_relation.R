


library(RODBC)

channel <- odbcConnect("FishLine")
fl_area_relation <-
  sqlQuery(channel, paste0("SELECT  DFUArea, areaICES
                              FROM        L_DFUArea"))
close(channel)

save(fl_area_relation, file = "fl_area_relation.Rdata")

