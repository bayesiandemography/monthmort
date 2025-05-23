
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(command)
})

cmd_assign(.data = "out/data.rds",
           end_date = as.Date("2020-01-31"),
           .out = "out/popn_change.rds")

data <- readRDS(.data)

popn_change <- data |>
  filter(time > end_date) |>
  select(-deaths) |>
  group_by(age, sex) |>
  filter(time %in% range(time)) |>
  mutate(time = ifelse(time == min(time), "start", "end")) |>
  pivot_wider(names_from = time, values_from = exposure) |>
  mutate(popn_change = 100 * (end - start) / start) |>
  select(age, sex, popn_change)

saveRDS(popn_change, file = .out)

