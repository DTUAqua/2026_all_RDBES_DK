# Prepare data, write CSV data tables

# Before:
# After:

library(icesTAF)
library(dplyr)
library(readxl)
library(openxlsx)
library(icesVocab)

mkdir("data")
# setwd("./adm")
getwd()

path_in <- "./boot/data/data_call/30939734/"
path_out <- ".data/"

year <- 2026

stocks <- icesVocab::getCodeList("IC_stock")

readme <- readxl::read_xlsx(paste0(path_in, "DC_Annex_1.xlsx"), sheet = 1)

dat <- c()

for (i in c(2:15)) {
  
  dat_0 <- readxl::read_xlsx(paste0(path_in, "DC_Annex_1.xlsx"), sheet = c(i))
  
  dat <- rbind(dat, dat_0)
}

dat$`Stock Key Label`[dat$`Stock Key Label` == "lin.27.346-91214"] <- "lin.27.3a4a6-91214"

nrow(dat)

dat <- left_join(dat, stocks, by = c("Stock Key Label" = "Key"))

dat$id <- row.names(dat)

names(dat)

head <- dat[, c(44, 1, 38, 3:6)]

unique(head$Country)
head_1 <- subset(head, Country %in% c("Denmark", "all countries"))


# AMS Landings and accosiated effort ----
lan <- dat[, c(44, 7:12, 34)]

lan_1 <- left_join(head_1, lan)

names(lan_1) <- gsub("Landings ", "", names(lan_1))

lan_1$type <- "AMS landings"

lan_2 <- subset(lan_1, !(is.na(Quantity)) | !(is.na(`Age Comp`)) | !(is.na(`Length Comp`)))

no_lan_kg <- subset(lan_1, !(id %in% lan_2$id))
no_lan_kg_1 <- subset(dat, id %in% no_lan_kg$id)


# BMS Landings ----

bms <- dat[, c(44, 13:18, 34)]
bms_1 <- left_join(head_1, bms)

names(bms_1) <- gsub("BMS Landings ", "", names(bms_1))

bms_1$type <- "BMS landings"
bms_1$responsible <- "Kirsten"

bms_2 <- subset(bms_1, !(is.na(Quantity)) | !(is.na(`Age Comp`)) | !(is.na(`Length Comp`)))

no_bms_kg <- subset(bms_1, !(id %in% bms_2$id))
no_bms_kg_1 <- subset(dat, id %in% no_bms_kg$id)


# Discards ----

dis <- dat[, c(44, 23:27, 34)]
dis_1 <- left_join(head_1, dis)

names(dis_1) <- gsub("Discards ", "", names(dis_1))

dis_1$`Mean Length At Age` <- NA
dis_1$type <- "Discard"

dis_1$responsible <- "Kirsten"

dis_2 <- subset(dis_1, !(is.na(Quantity)) | !(is.na(`Age Comp`)) | !(is.na(`Length Comp`)))

no_dis_kg <- subset(dis_1, !(id %in% dis_2$id))
no_dis_kg_1 <- subset(dat, id %in% no_dis_kg$id)

# Rekrea ----

rek <- dat[, c(44, 19:22, 34)]
rek_1 <- left_join(head_1, rek)

rek_1 <- rename(rek_1,  "Recreational Catch Quantity" = "Recreational Catch")

names(rek_1) <- gsub("Recreational Catch ", "", names(rek_1))
rek_1$type <- "Recreational Catch"

rek_1$responsible <- "Hans"

rek_2 <- subset(rek_1, !(is.na(Quantity)) | !(is.na(`Age Comp`)) | !(is.na(`Length Comp`)))

no_rek_kg <- subset(rek_1, !(id %in% rek_2$id))
no_rek_kg_1 <- subset(dat, id %in% no_rek_kg$id)


# Other ----

oth <- dat[, c(44, 28, 29, 30:33, 35)]

oth_g <- tidyr::gather(oth, key = "type", value = "Quantity", -id)

oth_1 <- left_join(head_1, oth_g)

oth_2 <- subset(oth_1, !(is.na(Quantity)))

no_oth_kg <- subset(oth_1, !(id %in% oth_2$id))
no_oth_kg_1 <- subset(dat, id %in% no_oth_kg$id)


# Final ----

final <- bind_rows(lan_2, dis_2, bms_2,  rek_2, oth_2)

final <- final[, c(1, 15, 2:14, 16)]

final$comment <- NA
final$submitted <- NA


# More responsible ----
final$responsible[final$type == "Discards Logbook Registered Quantity"] <- "Kirsten"
final$responsible[final$type == "Surveys"] <- "Jonathan"
final$responsible[final$type == "Sexual Maturity Data"] <- "Kirsten follow up"
final$comment[final$type == "Effort"]  <- "Jonathan responsible for effort input. responsible == IC uploader"

final$responsible[final$`Expert Group` == "HAWG"] <- "Kirsten"
final$responsible[final$`Expert Group` == "AFWG"] <- "Jonathan"
final$responsible[final$`Expert Group` == "NWWG"] <- "Jonathan"

final$responsible[final$`Expert Group` == "WGBFAS" &
                    final$type %in% c("AMS landings", "Effort")] <- "Jonathan"
final$responsible[final$`Expert Group` == "WGBFAS" &
                    final$type %in% c("AMS landings", "Effort") &
                    final$`Stock Key Label` %in% c("bzq.27.2425",
                                                   "fle.27.2223",
                                                   "her.27.25-2932",
                                                   "spr.27.22-32")] <- "Kirsten"


# WGBIE
final$responsible[final$`Expert Group` == "WGBIE" &
                    final$type %in% c("AMS landings", "Effort")] <- "Jonathan"


# WGNSSK

final$responsible[final$`Expert Group` == "WGNSSK" &
                    final$type %in% c("AMS landings", "Effort")] <- "Jonathan"

## Nep 
final$responsible[final$`Expert Group` == "WGNSSK" & final$type %in% c("AMS landings", "Effort") &
                    substr(final$`Stock Key Label`, 1, 3) == "nep"] <- "Kirsten"

## NOP
final$responsible[final$`Expert Group` == "WGNSSK" &
                    final$type %in% c("AMS landings", "Effort") &
                    final$`Stock Key Label` == "nop.27.3a4"] <- "Jonathan - Only landings in the spring, Kirsten - Biology in the Autumn"

## BLL, FLE
final$responsible[final$`Expert Group` == "WGNSSK" &
                    final$type %in% c("AMS landings", "Effort") &
                    final$`Stock Key Label` %in% c("bll.27.3a47de", "fle.27.3a4")] <- "Kirsten"
final$comment[final$`Expert Group` == "WGNSSK" &
                final$type %in% c("AMS landings") &
                final$`Stock Key Label` %in% c("bll.27.3a47de", "fle.27.3a4")] <- "Few length at-sea, see if it makes sense to submit biology"

## No samples, so only landings amount to be uploaded
final$comment[final$`Expert Group` == "WGNSSK" &
                final$type %in% c("AMS landings") &
                final$`Stock Key Label` %in% c("gug.27.3a47d", "mur.27.3a47d", "pol.27.3a4", "sol.27.4")] <- "No biology, so only amount of landings to be uploaded"
## Sex ratio
final$responsible[final$`Expert Group` == "WGNSSK" & final$type == "Sex Ratio" &
                    substr(final$`Stock Key Label`, 1, 3) == "nep"] <- "Kirsten"
