
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(lubridate)
  library(command)
})

cmd_assign(mod = "out/mod.rds",
           data = "out/data.rds",
           end_date = "2020-01-31",
           .out = "out/comp.rds")

newdata <- data |>
  filter(time > ymd(end_date))

comp <- mod |>
  forecast(newdata = newdata,
           output = "components",
           include_estimates = TRUE)

saveRDS(comp, file = .out)
