
# Extract from FishLine of commercial single fish information from area 22-24 for survey indicies

library(RODBC)


channel <- odbcConnect("FishLineDW")

dat <- 
  sqlQuery(
    channel,
    paste("SELECT     
    SpeciesList.sampleId,
    Age.ageId, 
    Age.animalId, 
    Age.year, 
    Age.cruise, 
    Age.trip, 
    Age.tripType, 
    Age.station, 
    Age.dateGearStart, 
    Age.quarterGearStart, 
    Age.dfuArea, 
    Age.statisticalRectangle,
    Sample.latPosStartDec, 
    Sample.lonPosStartDec, 
    Sample.latPosEndDec, 
    Sample.lonPosEndDec, 
    Age.gearType, 
    Age.meshSize, 
    Age.speciesCode, 
    Age.representative,
    Age.individNum, 
    Age.number, 
    Age.length, 
    Age.age,
    Age.agePlusGroup, 
    Age.otolithReadingRemark
FROM
    Age INNER JOIN
    Animal ON Age.animalId = Animal.animalId INNER JOIN
    SpeciesList ON Animal.speciesListId = SpeciesList.speciesListId INNER JOIN
    Sample ON SpeciesList.sampleId = Sample.sampleId
WHERE     (Age.year >= 2002) AND 
    (Age.speciesCode = 'SIL') AND 
    (Age.tripType <> 'VID') AND 
    (Age.dfuArea IN ('22', '23', '24', '25'))
ORDER BY 
    SpeciesList.sampleId,
    Age.ageId, 
    Age.animalId
    "
    ))


close(channel)

write.table(dat, "survey_indices_ALK_data_from_commercial.csv", sep = ",", row.names = F)