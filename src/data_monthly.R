
suppressPackageStartupMessages({
  library(dplyr)
  library(command)
})

cmd_assign(.data = "out/data.rds",
           .example_ages = "out/example_ages.rds",
           start_date = as.Date("1998-01-01"),
           end_date = as.Date("2020-01-31"),
           .out = "out/data_monthly.rds")

data <- readRDS(.data)
example_ages <- readRDS(.example_ages)

example_ages_short <- example_ages[c(1, 3, 5)]

data_monthly <- data |>
  filter(age %in% example_ages_short) |>
  filter(time >= start_date,
         time <= end_date)

saveRDS(data_monthly, file = .out)
