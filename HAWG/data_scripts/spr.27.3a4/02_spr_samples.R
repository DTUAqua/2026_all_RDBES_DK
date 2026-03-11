
library(RODBC)

years <- c(2023:2025)

channel <- odbcConnect("FishLineDW")
spr_samples_length <- sqlQuery(channel, paste0("SELECT Sample.sampleId, Sample.tripId, Sample.year, Sample.cruise, Sample.trip, Sample.tripType, Sample.station, Sample.stationName, Sample.labJournalNum, Sample.gearQuality, Sample.hydroStnRef, Sample.haulType, Sample.dateGearStart, 
                  Sample.dateGearEnd, Sample.timeZone, Sample.quarterGearStart, Sample.fishingtime, Sample.latPosStartText, Sample.lonPosStartText, Sample.latPosEndText, Sample.lonPosEndText, Sample.latPosStartDec, Sample.lonPosStartDec, 
                  Sample.latPosEndDec, Sample.lonPosEndDec, Sample.dfuArea, Sample.dfuAreaEnd, Sample.statisticalRectangle, Sample.statisticalRectangleEnd, Sample.distancePositions, Sample.distanceBottom, Sample.courseTrack, 
                  Sample.targetSpecies1, Animal.representative, Animal.individNum, Animal.number, Animal.length, Animal.weight, Animal.treatmentFactor,
                  SpeciesList.RaisingFactor
                  FROM     Sample INNER JOIN
                  SpeciesList ON Sample.sampleId = SpeciesList.sampleId INNER JOIN
                  Animal ON SpeciesList.speciesListId = Animal.speciesListId
                  WHERE  (Sample.targetSpecies1 = 'BRS') AND (Sample.year BETWEEN ", min(years), " AND ", max(years), ") 
                  AND (SpeciesList.speciesCode = 'BRS') AND (Animal.representative = 'ja') OR
                  (Sample.year BETWEEN ", min(years), " AND ", max(years), ") 
                                AND (Sample.cruise IN ('BRS15', 'BRS16', 'BRS17', 'BRS18', 'GUDP-VIND', 'BRS19', 'BRS20','IN-FISKER')) AND (SpeciesList.speciesCode = 'BRS') AND (Animal.representative = 'ja')"))

spr_samples_age <- sqlQuery(channel, paste("SELECT Sample.sampleId, Sample.tripId, Sample.year, Sample.cruise, Sample.trip, Sample.tripType, Sample.station, Sample.stationName, Sample.labJournalNum, Sample.gearQuality, Sample.hydroStnRef, Sample.haulType, Sample.dateGearStart, 
                  Sample.dateGearEnd, Sample.timeZone, Sample.quarterGearStart, Sample.fishingtime, Sample.latPosStartText, Sample.lonPosStartText, Sample.latPosEndText, Sample.lonPosEndText, Sample.latPosStartDec, Sample.lonPosStartDec, 
                  Sample.latPosEndDec, Sample.lonPosEndDec, Sample.dfuArea, Sample.dfuAreaEnd, Sample.statisticalRectangle, Sample.statisticalRectangleEnd, Sample.distancePositions, Sample.distanceBottom, Sample.courseTrack, 
                  Sample.targetSpecies1, Age.individNum, Age.number, Age.length, Age.age, Age.otolithReadingRemark
                  FROM     Sample INNER JOIN
                  SpeciesList ON Sample.sampleId = SpeciesList.sampleId INNER JOIN
                  Animal ON SpeciesList.speciesListId = Animal.speciesListId INNER JOIN
                  Age ON Animal.animalId = Age.animalId
                  WHERE  (Sample.targetSpecies1 = 'BRS') AND (Sample.year BETWEEN ", min(years), " AND ", max(years), ") 
                  AND (SpeciesList.speciesCode = 'BRS') OR
                  (Sample.year BETWEEN ", min(years), " AND ", max(years), ") 
                  AND (Sample.cruise IN ('BRS15', 'BRS16', 'BRS17', 'BRS18', 'GUDP-VIND', 'BRS19', 'BRS20','IN-FISKER')) AND (SpeciesList.speciesCode = 'BRS')"))

close(channel)

save(spr_samples_length, file = "spr_samples_length.RData")
save(spr_samples_age, file = "spr_samples_age.RData")

