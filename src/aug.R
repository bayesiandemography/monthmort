
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(.mod = "out/mod.rds",
           .data = "out/data.rds",
           end_date = as.Date("2020-01-31"),
           .out = "out/aug.rds")

mod <- readRDS(.mod)
data <- readRDS(.data)

newdata <- data |>
  filter(time > end_date)

aug <- mod |>
  forecast(newdata = newdata,
           include_estimates = TRUE)

saveRDS(aug, file = .out)
