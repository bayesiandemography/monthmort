
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(command)
})

cmd_assign(forecast = "out/forecast.rds",
           data = "out/data.rds",
           .out = "out/excess_deaths.rds")

expected <- forecast |>
  select(age, sex, time, expected = .deaths, exposure)

observed <- data |>
  select(age, sex, time, observed = deaths)

excess <- inner_join(expected, observed, by = c("age", "sex", "time")) |>
  mutate(excess = observed - expected)

saveRDS(excess, file = .out)

