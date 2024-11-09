
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(mod = "out/mod_excess.rds",
           data = "out/data.rds",
           aug = "out/aug_excess.rds",
           .out = "out/aug.rds")

set.seed(0)

date_final_estimate <- aug |>
  pull(time) |>
  max()
  
newdata <- data |>
  filter(time > date_final_estimate)

forecast <- mod |>
  forecast(newdata = newdata)

saveRDS(forecast, file = .out)
