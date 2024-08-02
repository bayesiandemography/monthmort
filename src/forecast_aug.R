
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(rvec, warn.conflicts = FALSE)
library(command)

cmd_assign(mod = "out/mod.rds",
           .out = "out/forecast_aug.rds")

labels <- seq(from = as.Date("2020-02-15"),
              by = "month",
              to = as.Date("2024-03-15"))

forecast_aug <- forecast(object = mod,
                         labels = labels,
                         include_estimates = TRUE) |>
  mutate(draws_ci(.fitted))

saveRDS(forecast_aug, file = .out)

