
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(mod = "out/mod_precovid.rds",
           data = "out/data.rds",
           aug = "out/aug_precovid.rds",
           .out = "out/aug.rds")

date_final_estimate <- aug |>
  pull(time) |>
  max()
  
newdata <- data |>
  filter(time > date_final_estimate)

forecast <- mod |>
  forecast(newdata = newdata)

saveRDS(forecast, file = .out)
