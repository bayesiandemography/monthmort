
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(lubridate)
  library(command)
})

cmd_assign(aug = "out/aug.rds",
           data = "out/data.rds",
           end_date = "2020-01-31",
           .out = "out/excess.rds")

end_date <- ymd(end_date)

expected <- aug |>
  filter(time > end_date) |>
  select(age, sex, time, expected = deaths, exposure)

observed <- data |>
  select(age, sex, time, observed = deaths)

excess <- inner_join(expected, observed, by = c("age", "sex", "time")) |>
  mutate(excess = observed - expected)

saveRDS(excess, file = .out)

