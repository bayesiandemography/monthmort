
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(.heldback = "out/heldback.rds",
           .out = "out/vals_heldback.rds")

heldback <- readRDS(.heldback)

vals_all <- heldback |>
  group_by(end_year) |>
  summarize(deaths_forecast = sum(deaths_forecast / 1000),
            deaths_true = sum(deaths_true / 1000)) |>
  mutate(draws_ci(deaths_forecast)) |>
  mutate(age = "Total")

vals_age <- heldback |>
  mutate(age = age_lower(age),
         age = 10 * (age %/% 10),
         age = case_when(age < 50 ~ "0-49",
                         age >= 50 & age < 90 ~ paste(age, age + 9, sep = "-"),
                         age >= 90 ~ "90+"),
         age = paste("Age", age)) |>
  group_by(end_year, age) |>
  summarize(deaths_forecast = sum(deaths_forecast / 1000),
            deaths_true = sum(deaths_true / 1000),
            .groups = "drop") |>
  mutate(draws_ci(deaths_forecast))
  

vals <- bind_rows(vals_all, vals_age) |>
  mutate(age = factor(age, levels = unique(age))) |>
  mutate(end_year = as.integer(end_year),
         forecast_period = paste(end_year, end_year + 5, sep = "-"))

saveRDS(vals, file = .out)
