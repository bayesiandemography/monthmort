
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(.mod = "out/mod.rds",
           .data = "out/data.rds",
           end_date = as.Date("2020-01-31"),
           .out = "out/comp.rds")

mod <- readRDS(.mod)
data <- readRDS(.data)

newdata <- data |>
  filter(time > end_date)

comp <- mod |>
  forecast(newdata = newdata,
           output = "components",
           include_estimates = TRUE)

saveRDS(comp, file = .out)
