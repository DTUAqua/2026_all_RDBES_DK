# DFAD_data_for_fleet_qouta_check, 2024
# Masked extract of DFAD data for checking the difference between metier fleets and quotas deduction

library(dplyr)
library(lubridate)

years <- c(2024)

path_dfad <- "Q:/20-forskning/20-dfad/data/Data/udvidet_data/"

# Get DFAD'et ----
## Only trips with herring landings

dfad <- c()

for (i in years) {
  dfad_0 <- readRDS(paste0(path_dfad, "dfad_udvidet", i, ".rds"))
  
  her_trips <- subset(dfad_0, art == "SIL")
  
  dfad_01 <- subset(dfad_0, match_alle %in% her_trips$match_alle)
  
  dfad <- bind_rows(dfad, dfad_01)
  
}

rm(dfad_0, dfad_01, her_trips)

# Mask match_alle ----

match <- distinct(dfad, match_alle)
match$id <- row.names(match)

dfad_1 <- merge(dfad, match)

# Add stuff ----

dfad_1$year <- year(dfad_1$ldato)
dfad_1$quarter <- quarter(dfad_1$ldato)

## Determine target species with FST' method, more or less

target_art <- aggregate(
  hel ~ ldato + fid + afrfvd + zone + art,
  data = dfad_1,
  FUN = sum,
  na.rm = T
)
target_tot <- aggregate(
  hel ~ ldato + fid + afrfvd + zone,
  data = dfad_1,
  FUN = sum,
  na.rm = T
)

target <- merge(
  target_art,
  target_tot,
  by = c(
    "ldato",
    "fid",
    "afrfvd",
    "zone"
  )
)
target$pct <- target$hel.x / target$hel.y

target_1 <- arrange(target, ldato, fid, afrfvd, zone, -pct)

target_2 <- slice(group_by(target_1, ldato, fid, afrfvd, zone), 1)

target_2$target_fst <- target_2$art

dfad_2 <- left_join(dfad_1,
                           select(target_2, ldato, fid, afrfvd, zone, target_fst))

rm(target_art, target_tot, target, target_1, target_2)

## Determine target species per trip

target_art <- aggregate(hel ~ id + art,
                        data = dfad_1,
                        FUN = sum,
                        na.rm = T)
target_tot <- aggregate(hel ~ id,
                        data = dfad_1,
                        FUN = sum,
                        na.rm = T)

target <- merge(target_art, target_tot, by = c("id"))
target$pct <- target$hel.x / target$hel.y

target_1 <- arrange(target, id, -pct)

target_2 <- slice(group_by(target_1, id), 1)

target_2$target_trip <- target_2$art

dfad_3 <- left_join(dfad_2, select(target_2, id, target_trip))

rm(target_art, target_tot, target, target_1, target_2)

dat <- dfad_3

# Summarise ----


dfad_sum <- aggregate(
  hel ~ id + oal + ob + lic_nr + year + quarter + 
    art + ltilst + anvend + ihovedart +
    afrfvd + fvd +
    dfadfvd_ret + dfadfvd_mrk + square_ret + square_ret_mrk +
    redskb + maske + metier_level6_ret + metier_level_6_new + metier_level_6_new_mrk +
    target_fst + target_trip,
  data = dat,
  FUN = sum,
  na.rm = T
)

dfad_sum_her <- subset(dfad_sum, art == "SIL")

write.table(
  dfad_sum_her,
  "DFAD_data_for_fleet_qouta_check.csv",
  sep = ",",
  row.names = F
)
