
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(lubridate)
  library(command)
})

cmd_assign(mod = "out/mod.rds",
           data = "out/data.rds",
           end_date = "2020-01-31",
           .out = "out/aug.rds")

newdata <- data |>
  filter(time > ymd(end_date))

aug <- mod |>
  forecast(newdata = newdata,
           include_estimates = TRUE)

saveRDS(aug, file = .out)
