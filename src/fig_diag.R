
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(poputils)
  library(ggplot2)
})

cmd_assign(aug = "out/aug_excess.rds",
           col_line = "darkblue",
           col_fill = "lightblue",
           col_point = "red",
           .out = "out/fig_diag_excess.pdf")


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
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Age-sex-specific mortality rates", subtitle = paste("Age", level_age))
}

p_det_rates <- lapply(levels_age, plot_det_rates)


## Mortality rates - aggregated -----------------------------------------------

## Age-sex

data_ag_agesex <- aug |>
  mutate(expected_deaths = .fitted * exposure) |>
  group_by(age, sex) |>
  summarise(deaths = sum(deaths),
            expected_deaths = sum(expected_deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(modelled = expected_deaths / exposure,
         direct = deaths / exposure) |>
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
  ggtitle("Aggregated mortality rates by age and sex")


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
         direct = deaths / exposure) |>
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
  mutate(year = format(time, format = "%Y"),
         year = as.integer(year)) |>
  filter(year %in% year_complete) |>
  mutate(expected_deaths = .fitted * exposure) |>
  group_by(sex, year) |>
  summarise(deaths = sum(deaths),
            expected_deaths = sum(expected_deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(modelled = expected_deaths / exposure,
         direct = deaths / exposure) |>
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
for (p in p_det_rates)
  plot(p)
plot(p_ag_agesex)
plot(p_ag_monthyear)
plot(p_ag_sexyear)
plot(p_lifeexp)
dev.off()        
