

# Create example data

library(RODBC)
library(dplyr)

path_out <- "./HAWG/data/exploring_alternative_estimators/"
channel <- odbcConnect("FishLineDW")

# Get data ----

sp <-
  sqlQuery(
    channel,
    paste(
      "SELECT     SpeciesList.speciesListId, Sample.sampleId, Sample.tripId, Sample.year, Sample.cruise, Sample.trip, Sample.station, Sample.quarterGearStart, Sample.dfuArea, Sample.targetSpecies1, Sample.gearType, Sample.meshSize, SpeciesList.speciesCode, SpeciesList.treatment, SpeciesList.treatmentFactor,
                  SpeciesList.totalWeight, SpeciesList.wemTotalWeight, SpeciesList.weightStep0, SpeciesList.weightStep1, SpeciesList.weightStep2, SpeciesList.raisingFactor, Animal.representative, Animal.number, Animal.length, Animal.weight
FROM        Sample INNER JOIN
                  SpeciesList ON Sample.sampleId = SpeciesList.sampleId INNER JOIN
                  Animal ON SpeciesList.speciesListId = Animal.speciesListId
WHERE     (Sample.year = 2025) AND (Sample.cruise = 'IN-FISKER') AND (Sample.dfuArea = '4B') AND (Sample.quarterGearStart = 4) AND (Animal.representative = 'ja')"
    )
  )

sampleWeightSpecies <- distinct(sp, sampleId, speciesListId, weightStep0, weightStep1, weightStep2, raisingFactor)

sampleWeightSpecies <- mutate(group_by(sampleWeightSpecies, speciesListId),
                              sampleWeightSpecies = 
                                       min(weightStep0, 
                                           weightStep1, 
                                           weightStep2, na.rm = T) * 
                                           raisingFactor)

sampleWeightAllSpecies_sum <- summarise(group_by(sampleWeightSpecies, sampleId), sampleWeightAllSpecies = 
               sum(sampleWeightSpecies))

sp_1 <- left_join(sp, select(sampleWeightAllSpecies_sum, sampleId, sampleWeightAllSpecies))

write.table(sp_1, paste0(path_out, "example_data_samples.csv"), row.names = F,
            sep = ";")

