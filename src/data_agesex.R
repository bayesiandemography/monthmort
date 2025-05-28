
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(lubridate)
  library(command)
})

cmd_assign(.data = "out/data.rds",
           .out = "out/data_agesex.rds")

data <- readRDS(.data)

sample_dates <- seq(from = as.Date("2015-01-15"),
                     to = as.Date("2020-01-15"),
                     by = "5 years")

data_agesex <- data |>
  filter(time %in% sample_dates) |>
  mutate(age = combine_age(age, to = "five")) |>
  group_by(age, sex, time) |>
  summarise(deaths = sum(deaths), exposure = sum(exposure),
            .groups = "drop") |>
  mutate(log_rates = log(deaths / exposure)) |>
  pivot_longer(c(deaths, exposure, log_rates),
               names_to = "series")

library(RColorBrewer)
ggplot(data_agesex,
       aes(x = age_mid(age), y = value, color = factor(time))) +
  facet_grid(vars(series), vars(sex), scale = "free_y") +
  geom_line() +
  scale_color_manual(values = c("#63a3cc", "#08306b"))



data_time <- data |>
  filter(age %in% c("10-14", "60-64", "95+")) |>
  mutate(rate = deaths / exposure)

ggplot(data_time,
       aes(x = time, y = rate)) +
  facet_grid(vars(age), vars(sex), scale = "free_y") +
  ylim(0, NA) +         
  geom_point(size = 0.2)


  scale_color_manual(values = c("#63a3cc", "#08306b"))



pc_change <- data |>
  filter(age_lower(age) >= age_min) |> 
  filter(time >= date_start,
         time <= date_end) |>
  mutate(year = year(time)) |>
  filter(year %in% range(year)) |>
  mutate(time = ifelse(year == min(year), "start", "end")) |>
  group_by(age, sex, time) |>
  summarise(deaths = sum(deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(rate = deaths / exposure) |>
  pivot_longer(c(rate, exposure, deaths), names_to = "series") |>
  pivot_wider(names_from = time, values_from = value) |>
  mutate(pc_change = 100 * (end - start) / start) |>
  select(-start, -end) |>
  mutate(series = factor(series,
                         levels = c("deaths", "exposure", "rate"),
                         labels = c("Deaths", "Exposure", "Deaths / Exposure")))

saveRDS(pc_change, file = .out)









