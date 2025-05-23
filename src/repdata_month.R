
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(lubridate)
  library(command)
})

cmd_assign(.mod = "out/mod.rds",
           .out = "out/repdata_month.rds")

mod <- readRDS(.mod)

set.seed(1) ## different from repdata_life so not using same draws

repdata_month <- mod |>
  replicate_data() |>
  mutate(year = year(time),
         month = month(time)) |>
  filter(year %in% 1999:2019) |>
  count(.replicate, year, month, wt = deaths, name = "deaths") |>
  mutate(deaths = deaths / 1000)

saveRDS(repdata_month, file = .out)
