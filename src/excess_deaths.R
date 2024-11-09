
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(mod = "out/mod_excess.rds",
           data = "out/data.rds",
           end_date = "2020-02-01",
           .out = "out/aug.rds")

newdata <- data |>
  filter(time >= end_date)

aug <- forecast(object = mod,
                newdata = newdata,
                include_estimates = TRUE) |>
  mutate(draws_ci(.fitted))

saveRDS(aug, file = .out)


library(bage, quietly = TRUE)
library(dplyr, quietly = TRUE)
library(command)

cmd_assign(data = "out/data.rds",
           aug = "out/aug.rds",
           end_date = "2020-02-01",
           col_fill = "lightblue",
           col_line = "black",
           col_point = "red",
           .out = "out/aug.rds")

expected <- aug |>
  select(age, sex, time, .fitted, expected = .deaths)

actual <- data |>
  filter(time >= end_date) |>
  rename(actual = deaths)

excess_deaths <- left_join(actual, expected, by = c("age", "sex", "time")) |>
  mutate(excess = actual - expected) |>
  mutate(draws_ci(excess))

library(ggplot2)

p_female <- excess_deaths |>
  filter(sex == "Female") |>
  ggplot(aes(x = time,
             y = excess.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill,
              alpha = 0.5) +
  geom_line(col = col_line) +
  geom_hline(yintercept = 0,
             linetype = "dotted") +
  ylab("") +
  xlab("Time") +
  theme(text = element_text(size = 18))


p_male <- excess_deaths |>
  filter(sex == "Male") |>
  ggplot(aes(x = time,
             y = excess.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill,
              alpha = 0.5) +
  geom_line(col = col_line) +
  geom_hline(yintercept = 0,
             linetype = "dotted") +
  ylab("") +
  xlab("Time") +
  theme(text = element_text(size = 18))


p_total <- excess_deaths |>
  count(age, time, wt = excess, name = "excess") |>
  mutate(draws_ci(excess)) |>
  ggplot(aes(x = time,
             y = excess.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill,
              alpha = 0.5) +
  geom_line(col = col_line) +
  geom_hline(yintercept = 0,
             linetype = "dotted") +
  ylab("") +
  xlab("Time") +
  theme(text = element_text(size = 18))



p_cumulative <- excess_deaths |>
  count(age, time, wt = excess, name = "excess") |>
  group_by(age) |>
  mutate(excess = cumsum(excess)) |>
  mutate(draws_ci(excess, width = c(0.8, 0.95))) |>
  ggplot(aes(x = time,
             y = excess.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill,
              alpha = 0.5) +
  geom_ribbon(aes(ymin = excess.lower1,
                  ymax = excess.upper1),
              fill = "blue",
              alpha = 0.5) +
  geom_line(col = col_line) +
  geom_hline(yintercept = 0,
             linetype = "dotted") +
  ylab("") +
  xlab("Time")





p_cumulative_total <- excess_deaths |>
  count(time, wt = excess, name = "excess") |>
  mutate(excess = cumsum(excess)) |>
  mutate(draws_ci(excess)) |>
  ggplot(aes(x = time,
             y = excess.mid)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill,
              alpha = 0.5) +
  geom_line(col = col_line) +
  geom_hline(yintercept = 0,
             linetype = "dotted") +
  ylab("") +
  xlab("Time")



library(poputils)
library(tidyr)

fit_one <- function(x) {
  mod <- mod_pois(actual ~ age * time,
                  data = x,
                  exposure = exp_all)
  fit(mod)
}
  
dd <- excess_deaths |>
  filter(age_lower(age) >= 50) |>
  mutate(exp_all = .fitted * exposure) |>
  group_by(age, time) |>
  summarize(actual = sum(actual),
            exp_all = sum(exp_all),
            .groups = "drop") |>
  expand_from_rvec() |>
  filter(draw <= 5) |>
  group_by(draw) |>
  nest() |>
  mutate(mod = lapply(data, fit_one)) |>
  mutate(augment = lapply(mod, augment)) |>
  select(-c(data, mod)) |>
  unnest(augment) |>
  mutate(draws_ci(.fitted))

  
p <- ggplot(dd, aes(x = time)) +
  facet_grid(vars(draw), vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(aes(y = .fitted.mid),
            col = col_line) +
  geom_hline(yintercept = 1,
             linetype = "dotted") +
  ylab("") +
  xlab("Time")
  



  
  







aug <- forecast(object = mod,
                newdata = newdata,
                include_estimates = TRUE) |>
  mutate(draws_ci(.fitted))

saveRDS(aug, file = .out)
