
suppressPackageStartupMessages({
  library(rvec)
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(ggplot2)
  library(command)
})

 
cmd_assign(forecast = "out/forecast.rds",
           aug = "out/aug_precovid.rds",
           col_fill = "lightblue",
           col_line = "darkblue",
           col_point = "red",
           .out = "out/fig_diag_forecast.pdf")

date_start_forecast <- forecast |>
  pull(time) |>
  min()


## Super-population mortality rates - maximum detail --------------------------

levels_age <- levels(aug$age)
plot_super_rates <- function(level_age) {
  data <- bind_rows(aug, forecast) |>
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
    geom_vline(xintercept = date_start_forecast,
               linetype = "dashed") +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Age-sex-specific mortality rates: Super-population",
            subtitle = paste("Age", level_age))
}

p_super_rates <- lapply(levels_age, plot_super_rates)


## Finte-population mortality rates - maximum detail -------------------------

levels_age <- levels(aug$age)
plot_finite_rates <- function(level_age) {
  data <- bind_rows(aug, forecast) |>
    filter(age == level_age) |>
    mutate(finite = .deaths / exposure) |>
    mutate(draws_ci(finite))
  ggplot(data,
         aes(x = time,
             y = finite.mid)) +
    facet_wrap(vars(sex), nrow = 2) +
    geom_ribbon(aes(ymin = finite.lower,
                    ymax = finite.upper),
                fill = col_fill) +
    geom_line(color = col_line,
              linewidth = 0.2) +
    geom_vline(xintercept = date_start_forecast,
               linetype = "dashed") +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Age-sex-specific mortality rates: Finite population",
            subtitle = paste("Age", level_age))
}

p_finite_rates <- lapply(levels_age, plot_finite_rates)


## Mortality rates - aggregated -----------------------------------------------

## Month-year

data_ag_monthyear <- bind_rows(aug, forecast) |>
  mutate(month = format(time, format = "%B"),
         month = factor(month, levels = month.name),
         year = format(time, format = "%Y"),
         year = as.integer(year)) |>
  mutate(expected_deaths = .fitted * exposure) |>
  group_by(year, month) |>
  summarise(expected_deaths = sum(expected_deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(rate = expected_deaths / exposure) |>
  mutate(draws_ci(rate))
  
p_ag_monthyear <- ggplot(data_ag_monthyear, aes(x = year)) +
  facet_wrap(vars(month)) +
  geom_ribbon(aes(ymin = rate.lower,
                  ymax = rate.upper),
              fill = col_fill) +
  geom_line(aes(y = rate.mid),
            color = col_line) +
  geom_vline(xintercept = 2020,
             linetype = "dashed") +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Aggregated mortality rates by month and year")


## Sex-year

n_obs <- bind_rows(aug, forecast) |>
  mutate(year = format(time, format = "%Y")) |>
  count(year)

year_complete <- n_obs |>
  filter(n == max(n)) |>
  pull(year)
         
data_ag_sexyear <- bind_rows(aug, forecast) |>
  mutate(year = format(time, format = "%Y"),
         year = as.integer(year)) |>
  filter(year %in% year_complete) |>
  mutate(expected_deaths = .fitted * exposure) |>
  group_by(sex, year) |>
  summarise(expected_deaths = sum(expected_deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(rate = expected_deaths / exposure) |>
  mutate(draws_ci(rate))
  
p_ag_sexyear <- ggplot(data_ag_sexyear, aes(x = year)) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = rate.lower,
                  ymax = rate.upper),
              fill = col_fill) +
  geom_line(aes(y = rate.mid),
            color = col_line) +
  geom_vline(xintercept = 2020,
             linetype = "dashed") +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Aggregated mortality rates by sex and year")


## Life expectancy ------------------------------------------------------------

data_lifeexp <- bind_rows(aug, forecast) |>
  lifeexp(mx = .fitted,
          by = c(sex, time)) |>
  rename(modelled = ex) |>
  mutate(draws_ci(modelled))

p_lifeexp <- ggplot(data_lifeexp, aes(x = time, groups = sex)) +
  geom_ribbon(aes(ymin = modelled.lower,
                  ymax = modelled.upper),
              fill = col_fill) +
  geom_line(aes(y = modelled.mid),
            color = col_line) +
  xlab("") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Life expectancy")


## Print in one document ------------------------------------------------------

graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
for (p in p_super_rates)
  plot(p)
for (p in p_finite_rates)
  plot(p)
plot(p_ag_monthyear)
plot(p_ag_sexyear)
plot(p_lifeexp)
dev.off()        
