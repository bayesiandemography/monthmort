
suppressPackageStartupMessages({
  library(dplyr)
  library(command)
})

cmd_assign(.data = "out/data.rds",
           .example_ages = "out/example_ages.rds",
           .out = "out/data_monthly.rds")

data <- readRDS(.data)
example_ages <- readRDS(.example_ages)

example_ages_short <- example_ages[c(1, 3, 5)]

data_monthly <- data |>
  filter(age %in% example_ages_short) |>
  mutate(rate = deaths / exposure)

saveRDS(data_monthly, file = .out)
