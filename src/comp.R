
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(rvec, warn.conflicts = FALSE)
library(command)

cmd_assign(mod = "out/mod.rds",
           data = "out/data.rds",
           end_date = "2020-02-01",
           .out = "out/comp.rds")

newdata <- data |>
  filter(time >= end_date)

comp <- forecast(object = mod,
                 newdata = newdata,
                 output = "components",
                 include_estimates = TRUE) |>
  mutate(draws_ci(.fitted))

saveRDS(comp, file = .out)

