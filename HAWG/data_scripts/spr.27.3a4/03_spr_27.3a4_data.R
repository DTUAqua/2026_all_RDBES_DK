## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)
library(dplyr)

mkdir("data")


# Prepare landings ----

load("boot/data/spr_dfad/spr_dfad.Rdata")

unique(spr_dfad$fao_area)
unique(spr_dfad$year)
table(spr_dfad$year, spr_dfad$fao_area)

spr.27.3a4_lan <-
  subset(spr_dfad,
         fao_area %in% c("27.3.a.20", "27.3.a.21", "27.4.a", "27.4.b", "27.4.c"))

save(spr.27.3a4_lan, file = "data/spr.27.3a4_lan.Rdata")

# Prepare sample data ----
## Get relations

load("boot/data/fl_area_relation/fl_area_relation.Rdata")

## Lengths ----
### Filter data

load("boot/data/spr_samples/spr_samples_length.Rdata")

spr_samples_length_1 <-
  left_join(spr_samples_length, fl_area_relation, by = c("dfuArea" = "DFUArea"))

unique(spr_samples_length_1$areaICES)

spr.27.3a4_samples_length <-
  subset(spr_samples_length_1,
         areaICES %in% c("27.3.a.20", "27.3.a.21", "27.4.a", "27.4.b", "27.4.c"))

unique(spr.27.3a4_samples_length$cruise)

### Format lengths and date
#### It is on purpose that the sub-sample is not multiplied with the raising factor 
#### - that would only scale the sub-sample to the more or less arbitrary sample size from the trip / haul
#### It would be correct to scale it to the total catch of the trip / haul, 
#### but as long as we don't do that, then I think it is better to have more or less equal sample size -> the sub-sample
#### This could be tested during the benchmark.
#### The idea is that the levels within the estimations should weight the samples according to the catches.
#### The latter is T if most of the estimations are done at the finer levels.

spr.27.3a4_samples_length <-
  mutate(
    spr.27.3a4_samples_length,
    length_scm = (0.5 * floor(length * 0.2) * 2),
    date = format(dateGearEnd, "%Y%m%d"),
    ctry = "DK",
    weight_whole = weight * treatmentFactor
  )
test_scm <- distinct(spr.27.3a4_samples_length, length, length_scm)
test_date <- distinct(spr.27.3a4_samples_length, dateGearEnd, date)

save(spr.27.3a4_samples_length, file = "data/spr.27.3a4_samples_length.Rdata")

## Ages ----
### Filter data

load("boot/data/spr_samples/spr_samples_age.Rdata")

spr_samples_age_1 <-
  left_join(spr_samples_age, fl_area_relation, by = c("dfuArea" = "DFUArea"))

unique(spr_samples_age_1$areaICES)


unique(spr_samples_age_1$otolithReadingRemark)

spr_samples_age_1$age[spr_samples_age_1$otolithReadingRemark %in% c("AQ3", "AQ3_QA")] <- NA


spr.27.3a4_samples_age <-
  subset(spr_samples_age_1,
         areaICES %in% c("27.3.a.20", "27.3.a.21", "27.4.a", "27.4.b", "27.4.c") & !(is.na(age)))


### Format lengths and date

spr.27.3a4_samples_age <-
  mutate(
    spr.27.3a4_samples_age,
    length_scm = (0.5 * floor(length * 0.2) * 2),
    date = format(dateGearEnd, "%Y%m%d"),
    ctry = "DK",
    age_plus = ifelse(age > 4, paste("age_", 4, sep = ""), paste("age_", age, sep = ""))
  )

test_scm <- distinct(spr.27.3a4_samples_age, length, length_scm)
test_date <- distinct(spr.27.3a4_samples_age, dateGearEnd, date)
test_age_plus <- distinct(spr.27.3a4_samples_age, age, age_plus)

save(spr.27.3a4_samples_age, file = "data/spr.27.3a4_samples_age.Rdata")
