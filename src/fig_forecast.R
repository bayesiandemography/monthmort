
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec, warn.conflicts = FALSE)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
 
cmd_assign(forecast_aug = "out/forecast_aug.rds",
           forecast_comp = "out/forecast_comp.rds",
           .out = "out/fig_forecast.pdf")


## Settings -------------------------------------------------------------------

col_fill <- "lightblue2"
date_launch <- as.Date("2020-02-15")


## Hyper-parameters -----------------------------------------------------------

p_time <- forecast_comp %>%
  filter(component == "effect",
         term == "time") %>%
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(col = "darkblue",
            linewidth = 0.5) +
  geom_vline(xintercept = date_launch,
             linetype = "dashed") +
  scale_x_date(breaks = "1 year") +
  xlab("Time") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Time effect")

p_time_trend <- forecast_comp %>%
  filter(component == "trend",
         term == "time") %>%
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(col = "darkblue",
            linewidth = 0.5) +
  geom_vline(xintercept = date_launch,
             linetype = "dashed") +
  scale_x_date(breaks = "1 year") +
  xlab("Time") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Time trend")

p_time_cyclical <- forecast_comp %>%
  filter(component == "cyclical",
         term == "time") %>%
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(col = "darkblue",
            linewidth = 0.5) +
  geom_vline(xintercept = date_launch,
             linetype = "dashed") +
  scale_x_date(breaks = "1 year") +
  xlab("Time") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Time cyclical")

p_agetime <- forecast_comp %>%
  filter(component == "effect",
         term == "age:time") %>%
  separate_wider_delim(level,
                       delim = ".",
                       names = c("age", "time")) %>%
  mutate(age = reformat_age(age)) %>%
  ggplot(aes(x = as.Date(time),
             y = .fitted.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(col = "darkblue",
            linewidth = 0.5) +
  geom_vline(xintercept = date_launch,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Age:time effect")

p_agetime_trend <- forecast_comp %>%
  filter(component == "trend",
         term == "age:time") %>%
  separate_wider_delim(level,
                       delim = ".",
                       names = c("age", "time")) %>%
  ggplot(aes(x = as.Date(time),
             y = .fitted.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(col = "darkblue",
            linewidth = 0.5) +
  geom_vline(xintercept = date_launch,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Age:time trend")

p_agetime_seasonal <- forecast_comp %>%
  filter(component == "seasonal",
         term == "age:time") %>%
  separate_wider_delim(level,
                       delim = ".",
                       names = c("age", "time")) %>%
  mutate(age = reformat_age(age)) %>% 
  ggplot(aes(x = as.Date(time),
             y = .fitted.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(col = "darkblue",
            linewidth = 0.5) +
  geom_vline(xintercept = date_launch,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Age:time seasonal")



## Mortality rates ------------------------------------------------------------

levels_age <- levels(forecast_aug$age)
plot_age_rates <- function(level_age) {
  data <- filter(forecast_aug, age == level_age)
  ggplot(data,
         aes(x = time,
             y = .fitted.mid)) +
    facet_wrap(vars(sex), nrow = 2) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill) +
    geom_line(col = "darkblue",
              linewidth = 0.01) +
    geom_point(aes(y = .observed),
               col = "darkblue",
               size = 0.5) +
    geom_vline(xintercept = date_launch,
               linetype = "dashed") +
    scale_x_date(breaks = "1 year") +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Mortality rates", subtitle = paste("Age", level_age))
}

p_age_rates <- lapply(levels_age, plot_age_rates)


## Life expectancy ------------------------------------------------------------

p_lifeexp <- forecast_aug %>%
  lifeexp(mx = .fitted,
          by = c(sex, time)) %>%
  mutate(draws_ci(ex)) %>%
  ggplot(aes(x = time,
             ymin = ex.lower,
             y = ex.mid,
             ymax = ex.upper,
             fill = sex)) +
  geom_vline(xintercept = as.Date("2020-03-01"),
             linewidth = 0.5,
             linetype = "dotted") +
  geom_ribbon(alpha = 0.5) +
  geom_line(linewidth = 0.2) +
  geom_vline(xintercept = date_launch,
             linetype = "dashed") +
  scale_x_date(breaks = "1 year") +
  xlab("") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "top",
        legend.title = element_blank()) +
  ggtitle("Life expectancy")


## Print in one document ------------------------------------------------------

graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
plot(p_time)
plot(p_time_trend)
plot(p_time_cyclical)
plot(p_agetime)
plot(p_agetime_trend)
plot(p_agetime_seasonal)
for (p in p_age_rates)
    plot(p)
plot(p_lifeexp)
dev.off()        
