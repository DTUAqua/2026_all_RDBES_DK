# Run analysis, write model results

# Before:
# After:

library(icesTAF)
library(dplyr)

getwd()

mkdir("model")

# Summarise landings for template ----

load("data/spr.27.3a4/spr.27.3a4_lan.Rdata")

spr.27.3a4_lan_per_yq_area <- summarise(group_by(spr.27.3a4_lan, ctry, year, quarter, fao_area), catch_in_ton = sum(kg/1000), .groups = "drop")
spr.27.3a4_lan_per_yq_rect <- summarise(group_by(spr.27.3a4_lan, ctry, year, quarter, square_ret), catch_in_ton = sum(kg/1000), .groups = "drop")


save(spr.27.3a4_lan_per_yq_area, file = "model/spr.27.3a4_lan_per_yq_area.Rdata")
save(spr.27.3a4_lan_per_yq_rect, file = "model/spr.27.3a4_lan_per_yq_rect.Rdata")

# Summarise samples for template ----
## Length

load("data/spr.27.3a4/spr.27.3a4_samples_length.Rdata")

spr.27.3a4_lan_ld_per_sample <- summarise(group_by(spr.27.3a4_samples_length, ctry, date, statisticalRectangle, sampleId, length_scm), 
                                          weight_whole = sum(weight_whole, na.rm = T), number = sum(number))

save(spr.27.3a4_lan_ld_per_sample, file = "model/spr.27.3a4_lan_ld_per_sample.Rdata")

## Age

load("data/spr.27.3a4/spr.27.3a4_samples_age.Rdata")

age_spr_3a4_per_sample <- summarise(group_by(spr.27.3a4_samples_age, sampleId, length_scm, age_plus), no_aged = sum(number, na.rm = T), .groups = "drop")

age_spr_3a4_per_sample_t <- tidyr::spread(age_spr_3a4_per_sample, key = age_plus, value = no_aged, fill = 0)

### Test match between length in ld and ALK
alk_test <- full_join(spr.27.3a4_lan_ld_per_sample, age_spr_3a4_per_sample_t)

alk_test_sum <- summarise(group_by(filter(alk_test, is.na(date)), sampleId), no_length = sum(age_0 + age_1 + age_2 + age_3 + age_4, na.rm = T))

sum(alk_test_sum$no_length)

### We only have mean_weight in the ALK, so we need to add lengths with no ages
### determined to the ALK data to get all our weight in the data
alk_spr_3a4 <- left_join(spr.27.3a4_lan_ld_per_sample, age_spr_3a4_per_sample_t)

alk_spr_3a4$age_0[is.na(alk_spr_3a4$age_0)] <- 0
alk_spr_3a4$age_1[is.na(alk_spr_3a4$age_1)] <- 0
alk_spr_3a4$age_2[is.na(alk_spr_3a4$age_2)] <- 0
alk_spr_3a4$age_3[is.na(alk_spr_3a4$age_3)] <- 0
alk_spr_3a4$age_4[is.na(alk_spr_3a4$age_4)] <- 0

spr27.3a4_alk_per_sample <- mutate(alk_spr_3a4, prop_aged = (age_0 + age_1 + age_2 + age_3 + age_4) / number, mean_weight = weight_whole / number)

save(spr27.3a4_alk_per_sample, file = "model/spr.27.3a4_alk_per_sample.Rdata")

## Number of samples

samling_head <- distinct(spr.27.3a4_samples_length, sampleId, year,  quarterGearStart, areaICES)

sampling_number <- summarise(group_by(spr27.3a4_alk_per_sample, sampleId), no_lengthed = sum(number), no_aged = sum(age_0 + age_1 + age_2 + age_3 + age_4))

sampling_0 <- left_join(samling_head, sampling_number)

sampling_0$quarter <- sampling_0$quarterGearStart
sampling_0$fao_area <- sampling_0$areaICES

sampling_sum <- summarise(group_by(sampling_0, year, quarter, fao_area), no_samples = length(sampleId), no_lengthed = sum(no_lengthed), 
                          no_aged = sum(no_aged), .groups = "drop")

spr.27.3a4_no_samples <- left_join(spr.27.3a4_lan_per_yq_area, sampling_sum)

save(spr.27.3a4_no_samples, file = "model/spr.27.3a4_no_samples.Rdata")
