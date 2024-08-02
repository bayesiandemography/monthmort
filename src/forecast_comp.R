
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(rvec, warn.conflicts = FALSE)
library(command)

cmd_assign(mod = "out/mod.rds",
           .out = "out/forecast_comp.rds")

labels <- seq(from = as.Date("2020-02-15"),
              by = "month",
              to = as.Date("2024-03-15"))

forecast_comp <- forecast(object = mod,
                          labels = labels,
                          output = "components",
                          include_estimates = TRUE) |>
  mutate(draws_ci(.fitted))

saveRDS(forecast_comp, file = .out)

