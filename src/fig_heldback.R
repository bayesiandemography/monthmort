
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(.heldback = "out/heldback.rds",
           col_line = "darkorange",
           col_point = "#1F4E79",
           .out = "out/fig_heldback.pdf")

heldback <- readRDS(.heldback)

data_all <- heldback |>
  group_by(end_year) |>
  summarize(deaths_forecast = sum(deaths_forecast / 1000),
            deaths_true = sum(deaths_true / 1000)) |>
  mutate(draws_ci(deaths_forecast)) |>
  mutate(age = "Total")

data_age <- heldback |>
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
  

data <- bind_rows(data_all, data_age) |>
  mutate(age = factor(age, levels = unique(age))) |>
  mutate(end_year = as.integer(end_year),
         forecast_period = paste(end_year, end_year + 5, sep = "-"))

p <- ggplot(data, aes(x = forecast_period)) +
  facet_wrap(vars(age), scale = "free_y", nrow = 2) +
  geom_errorbar(aes(ymin = deaths_forecast.lower,
                    ymax = deaths_forecast.upper),
                color = col_line) +
  geom_point(aes(y = deaths_forecast.mid),
             color = col_line) +
  geom_point(aes(y = deaths_true),
             col = col_point,
             size = 1.2) +
  ylim(0, NA) +
  xlab("Forecast period") +
  ylab("Deaths (000)") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  

pdf(file = .out,
    width = 6,
    height = 6)
plot(p)
dev.off()
