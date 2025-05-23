
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(poputils)
  library(lubridate)
  library(ggplot2)
  library(patchwork)
})

cmd_assign(.aug = "out/aug.rds",
           .comp = "out/comp.rds",
           end_date = as.Date("2020-01-31"),
           col_line = "#1F4E79",
           col_fill = "#A6CEE3",
           col_point = "red",
           .out = "out/fig_diag_mod.pdf")

aug <- readRDS(.aug)
comp <- readRDS(.comp)


## Mortality rates - maximum detail -------------------------------------------

levels_age <- levels(aug$age)
plot_det_rates <- function(level_age) {
  data <- aug |>
    filter(age == level_age) |>
    mutate(draws_ci(.fitted))
  ggplot(data,
         aes(x = time,
             y = .fitted.mid)) +
    facet_wrap(vars(sex), nrow = 2) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill) +
    geom_line(color = col_line,
              linewidth = 0.2) +
    geom_point(aes(y = .observed),
               color = col_point,
               size = 0.5) +
    geom_vline(xintercept = end_date,
               linewidth = 0.2,
               linetype = "dashed") +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
    xlab("") +
    ylab("") +
    ggtitle("Age-sex-specific mortality rates", subtitle = paste("Age", level_age))
}

p_det_rates <- lapply(levels_age, plot_det_rates)


## Mortality rates - aggregated -----------------------------------------------

## Age-sex

data_ag_agesex <- aug |>
  filter(time <= end_date) |>
  mutate(expected_deaths = .fitted * exposure) |>
  group_by(age, sex) |>
  summarise(deaths = sum(deaths),
            expected_deaths = sum(expected_deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(modelled = expected_deaths / exposure,
         direct = draws_median(deaths / exposure)) |>
  mutate(draws_ci(modelled))
  
p_ag_agesex <- ggplot(data_ag_agesex, aes(x = age_mid(age))) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = modelled.lower,
                  ymax = modelled.upper),
              fill = col_fill) +
  geom_line(aes(y = modelled.mid),
            color = col_line) +
  geom_point(aes(y = direct),
             color = col_point) +
  scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Aggregated mortality rates by age and sex",
          subtitle = "(Estimation period only)")


## Month-year

data_ag_monthyear <- aug |>
  mutate(month = format(time, format = "%B"),
         month = factor(month, levels = month.name),
         year = format(time, format = "%Y"),
         year = as.integer(year)) |>
  mutate(expected_deaths = .fitted * exposure) |>
  group_by(year, month) |>
  summarise(deaths = sum(deaths),
            expected_deaths = sum(expected_deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(modelled = expected_deaths / exposure,
         direct = draws_median(deaths / exposure),
         direct = if_else(year >= year(end_date), NA, direct)) |>
  mutate(draws_ci(modelled))
  
p_ag_monthyear <- ggplot(data_ag_monthyear, aes(x = year)) +
  facet_wrap(vars(month)) +
  geom_ribbon(aes(ymin = modelled.lower,
                  ymax = modelled.upper),
              fill = col_fill) +
  geom_line(aes(y = modelled.mid),
            color = col_line) +
  geom_point(aes(y = direct),
             color = col_point) +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Aggregated mortality rates by month and year")


## Sex-year

n_obs <- aug |>
  mutate(year = format(time, format = "%Y")) |>
  count(year)

year_complete <- n_obs |>
  filter(n == max(n)) |>
  pull(year)
         
data_ag_sexyear <- aug |>
  mutate(year = year(time)) |>
  filter(year %in% year_complete) |>
  mutate(expected_deaths = .fitted * exposure) |>
  group_by(sex, year) |>
  summarise(deaths = sum(deaths),
            expected_deaths = sum(expected_deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(modelled = expected_deaths / exposure,
         direct = deaths / exposure,
         direct = draws_median(direct),
         direct = if_else(year >= year(end_date), NA, direct)) |>
  mutate(draws_ci(modelled))
  
p_ag_sexyear <- ggplot(data_ag_sexyear, aes(x = year)) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = modelled.lower,
                  ymax = modelled.upper),
              fill = col_fill) +
  geom_line(aes(y = modelled.mid),
            color = col_line) +
  geom_point(aes(y = direct),
             color = col_point) +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Aggregated mortality rates by sex and year")


## Life expectancy ------------------------------------------------------------

data_lifeexp_modelled <- aug |>
  lifeexp(mx = .fitted,
          by = c(sex, time)) |>
  rename(modelled = ex) |>
  mutate(draws_ci(modelled))

data_lifeexp_direct <- aug |>
  lifeexp(mx = .observed,
          by = c(sex, time)) |>
  rename(direct = ex)

data_lifeexp <- data_lifeexp_modelled |>
  inner_join(data_lifeexp_direct, by = c("sex", "time"))

p_lifeexp <- ggplot(data_lifeexp, aes(x = time, groups = sex)) +
  geom_ribbon(aes(ymin = modelled.lower,
                  ymax = modelled.upper),
              fill = col_fill) +
  geom_line(aes(y = modelled.mid),
            color = col_line) +
  geom_point(aes(y = direct),
             color = col_point,
             size = 0.7) +
  geom_vline(xintercept = end_date,
             linewidth = 0.2,
             linetype = "dashed") +
  xlab("") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Life expectancy")


## Time effect ----------------------------------------------------------------

data_time <- comp |>
  filter(term == "time") |>
  mutate(draws_ci(.fitted))  

p_time_effect <- data_time |>
  filter(component == "effect") |>
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(color = col_line,
            linewidth = 0.5) +
  geom_vline(xintercept = end_date,
             linewidth = 0.2,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Time main effect")

p_time_trend <- data_time |>
  filter(component == "trend") |>
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(color = col_line,
            linewidth = 0.5) +
  geom_vline(xintercept = end_date,
             linewidth = 0.2,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Time main effect: Trend term")

p_time_error <- data_time |>
  filter(component == "error") |>
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(color = col_line,
            linewidth = 0.5) +
  geom_vline(xintercept = end_date,
             linewidth = 0.2,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Time main effect: Cyclical term")

p_time <- p_time_effect / p_time_trend / p_time_error


## Print in one document ------------------------------------------------------

pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
for (p in p_det_rates)
  plot(p)
plot(p_ag_agesex)
plot(p_ag_monthyear)
plot(p_ag_sexyear)
plot(p_lifeexp)
plot(p_time)
dev.off()        
