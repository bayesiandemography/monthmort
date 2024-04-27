
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(mod = "out/mod.rds",
           .out = "out/forecast_aug.rds")

labels <- seq(from = as.Date("2020-02-15"),
              by = "month",
              to = as.Date("2024-03-15"))

forecast_aug <- forecast(object = mod,
                         labels = labels,
                         include_est = TRUE)

saveRDS(forecast_aug, file = .out)

library(ggplot2)
library(rvec)
library(poputils)

data_plot <- forecast %>%
  lifeexp(mx = .fitted, by = c(sex, time)) %>%
  mutate(draws_ci(ex))
print(data_plot, n = Inf)

p_ex <- ggplot(data_plot, aes(x = time)) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = ex.lower, ymax = ex.upper),
              fill = "lightblue") +
  geom_line(aes(y = ex.mid),
            col = "darkblue",
            linewidth = 0.25) +
  geom_vline(xintercept = as.Date("2020-02-01"),
             col = "darkred",
             linetype = "dotted")
plot(p_ex)


comp <- forecast(mod, output = "comp", labels = labels, include_est= T)

data_time <- filter(comp, term == "time", component == "effect") %>%
  mutate(draws_ci(.fitted))
p_time <- ggplot(data_time, aes(x = as.Date(level))) +
  geom_ribbon(aes(ymin = .fitted.lower, ymax = .fitted.upper),
              fill = "lightblue") +
  geom_line(aes(y = .fitted.mid),
            col = "darkblue",
            linewidth = 0.25)
plot(p_time)


data_trend <- filter(comp, term == "time", component == "trend") %>%
  mutate(draws_ci(.fitted))
p_trend <- ggplot(data_trend, aes(x = as.Date(level))) +
  geom_ribbon(aes(ymin = .fitted.lower, ymax = .fitted.upper),
              fill = "lightblue") +
  geom_line(aes(y = .fitted.mid),
            col = "darkblue",
            linewidth = 0.25)
plot(p_trend)


data_cyclical <- filter(comp, term == "time", component == "cyclical") %>%
  mutate(draws_ci(.fitted))

p_cyclical <- ggplot(data_cyclical, aes(x = as.Date(level))) +
  geom_ribbon(aes(ymin = .fitted.lower, ymax = .fitted.upper),
              fill = "lightblue") +
  geom_line(aes(y = .fitted.mid),
            col = "darkblue",
            linewidth = 0.25) 
plot(p_cyclical)
