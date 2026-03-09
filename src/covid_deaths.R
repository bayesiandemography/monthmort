
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(lubridate)
  library(command)
})

cmd_assign(.weekly = "data/weekly-deaths.csv",
           .out = "out/covid_deaths.rds")

weekly <- read_csv(.weekly,
                   skip = 1,
                   col_types = "D-i",
                   col_names = c("week", "deaths"))

covid_deaths <- weekly |>
  mutate(time = rollback(week) + 15) |>
  count(time, wt = deaths, name = "deaths")

saveRDS(covid_deaths, file = .out)

