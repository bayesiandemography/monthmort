
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(command)
})

cmd_assign(.data = "out/data.rds",
           .out = "out/data_deaths_expose.rds")

data <- readRDS(.data)

sample_dates <- as.Date(c("2015-01-15", "2020-01-15"))

make_age_mid <- function(x) {
  x$age_mid <- age_mid(x$age)
  x
}

data_deaths_expose <- data |>
  filter(time %in% sample_dates) |>
  mutate(log_rate = log(deaths / exposure)) |>
  pivot_longer(c(deaths, exposure, log_rate),
               names_to = "series") |>
  mutate(age = if_else(age %in% c("0", "1-4") &
                         series %in% c("deaths", "exposure"),
                       "0-4",
                       age)) |>
  count(age, sex, time, series, wt = value, name = "value") |>
  group_by(series) |>
  nest() |>
  mutate(data = lapply(data, make_age_mid)) |>
  unnest(data)

saveRDS(data_deaths_expose, file = .out)









