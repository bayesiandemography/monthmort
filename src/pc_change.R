
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(lubridate)
  library(command)
})

cmd_assign(.data = "out/data.rds",
           age_min = 50,
           date_start = "2015-01-01",
           date_end = "2019-12-31",
           .out = "out/pc_change.rds")

data <- readRDS(.data)

pc_change <- data |>
  filter(age_lower(age) >= age_min) |> 
  filter(time >= date_start,
         time <= date_end) |>
  mutate(year = year(time)) |>
  filter(year %in% range(year)) |>
  mutate(time = ifelse(year == min(year), "start", "end")) |>
  group_by(age, sex, time) |>
  summarise(deaths = sum(deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(rate = deaths / exposure) |>
  pivot_longer(c(rate, exposure, deaths), names_to = "series") |>
  pivot_wider(names_from = time, values_from = value) |>
  mutate(pc_change = 100 * (end - start) / start) |>
  select(-start, -end) |>
  mutate(series = factor(series,
                         levels = c("rate", "exposure", "deaths"),
                         labels = c("Rate", "Exposure", "Deaths")))

saveRDS(pc_change, file = .out)

