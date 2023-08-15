
library(readr)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(poputils)
library(command)

cmd_assign(.deaths = "data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2023M2.csv.gz",
           .out = "out/deaths.rds")

deaths <- read_csv(.deaths, col_types = "iicci") %>%
    mutate(time = sprintf("%d-%02.0f", year_death, month_death)) %>%
    select(-year_death, -month_death) %>%
    mutate(age = reformat_age(age_group)) %>%
    select(age, sex, time, count = deaths) %>%
    complete(age, sex, time, fill = list(count = 0L))

saveRDS(deaths, file = .out)

