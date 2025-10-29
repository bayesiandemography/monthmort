
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(lubridate)
  library(command)
})

cmd_assign(.deaths = "data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2025M6.csv.gz",
           end_date_all = as.Date("2025-02-28"),
           .out = "out/deaths.rds")

deaths <- read_csv(.deaths, col_types = "ii-cci") |>
  mutate(time = sprintf("%d-%02.0f", year_death, month_death)) |>
  select(-year_death, -month_death) |>
  mutate(age = reformat_age(age_group)) |>
  select(age, sex, time, deaths) |>
  complete(age, sex, time, fill = list(deaths = 0L)) |>
  mutate(time = paste0(time, "-15"),
         time = ymd(time)) |>
  filter(time <= end_date_all)

saveRDS(deaths, file = .out)

