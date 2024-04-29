
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(lubridate, warn.conflicts = FALSE)
library(poputils)
library(rvec)
library(tidyr)
library(ggplot2)

col_fill <- "lightblue"
col_line <- "darkblue"
col_point <- "red"


cmd_assign(deaths = "out/deaths.rds",
           exposure = "out/exposure.rds",
           start_date = "2010-02-01",
           end_date = "2020-02-01",
           .out = "out/mod.rds")

data <- inner_join(rename(deaths, deaths = count),
                   rename(exposure, exposure = count),
                   by = c("age", "sex", "time")) |>
    mutate(time = paste0(time, "-15"),
           time = ymd(time)) |>
    filter(time > ymd(start_date),
           time < ymd(end_date))

mod <- mod_pois(deaths ~ age:sex + time + age:time,
                data = data,
                exposure = exposure) |>
  set_prior(age:sex ~ ERW2()) |>
  set_prior(time ~ compose_time(Lin(s = 0.01), cyclical = AR())) |>
  set_prior(age:time ~ compose_time(ERW(s = 0.1), seasonal = ESeas(n = 12)))


mod <- mod |>
  fit()

aug <- augment(mod)

data_aug <- aug |>
    filter(time == max(time)) |>
    mutate(age = age_mid(age)) |>
    mutate(draws_ci(.fitted))

p <- ggplot(data_aug,
       aes(x = age,
           y = .fitted.mid)) +
    facet_wrap(vars(sex)) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill,
                alpha = 0.5) +
    geom_line(col = col_line,
              linewidth = 0.25) +
    geom_point(aes(y = .observed),
               col = col_point,
               size = 0.4) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    ylab("") +
    xlab("") +
    theme(text = element_text(size = 18))

data_le <- aug |>
  lifeexp(mx = .fitted,
          by = c(sex, time)) |>
  mutate(draws_ci(ex))

p <- ggplot(data_le,
            aes(x = time,
                y = ex.mid)) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = ex.lower,
                  ymax = ex.upper),
              fill = col_fill,
              alpha = 0.5) +
  geom_line(col = col_line,
            linewidth = 0.25) +
  ylab("") +
  xlab("")



comp <- components(mod)

data_at <- comp |>
  filter(term == "age:time",
         component != "hyper") |>
  separate_wider_delim(level, delim = ".", names = c("age", "time")) |>
  mutate(age = reformat_age(age)) |>
    filter(age %in% c("10-14", "40-44", "70-74", "95+")) |>
    mutate(time = as.Date(time)) |>
  mutate(draws_ci(.fitted)) |>
  mutate(component = factor(component,
                            levels = c("effect",
                                       "trend", "seasonal"),
                            labels = c("Age-time Interaction",
                                       "Trend Component",
                                       "Seasonal Component")),
         age = paste("Age", age))

p <- ggplot(data_at,
            aes(x = time,
                y = .fitted.mid)) +
  facet_grid(vars(age), vars(component)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = 0.5) +
  geom_line(col = col_line,
            linewidth = 0.25) +
  scale_x_date(breaks = "1 year",
               date_labels = "%Y") +
  ylim(-1, 1) +
  ylab("") +
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
