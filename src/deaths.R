
suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(lubridate)
  library(command)
})

cmd_assign(.deaths = "data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2026M3.xlsx",
           .out = "out/deaths.rds")

out <- read_xlsx(.deaths,
                 col_types = c("numeric", "numeric", "skip",
                               "text", "text", "numeric")) |>
  mutate(time = sprintf("%d-%02.0f", year_death, month_death)) |>
  select(-year_death, -month_death) |>
  mutate(age = reformat_age(age_group)) |>
  select(age, sex, time, deaths) |>
  complete(age, sex, time, fill = list(deaths = 0L)) |>
  mutate(time = paste0(time, "-15"),
         time = ymd(time))

saveRDS(out, file = .out)

