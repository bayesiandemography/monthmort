
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec, warn.conflicts = FALSE)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
library(patchwork)

cmd_assign(aug = "out/aug.rds",
           comp = "out/comp.rds",
           end_date = "2020-02-01",
           col_line = "darkblue",
           col_fill = "lightblue",
           col_point = "red",
           .out = "out/fig_diag.pdf")

end_date <- as.Date(end_date)
alpha <- 0.6

## Hyper-parameters -----------------------------------------------------------

p_age <- comp |>
  filter(component == "effect",
         term == "age") |>
  rename(age = level) |>
  mutate(age = reformat_age(age)) |> 
  ggplot(aes(x = age_mid(age),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.5) +
  xlab("Age") +
  ylab("") +
  ggtitle("Age main effect")

p_agesex <- comp |>
  filter(component == "effect",
         term == "age:sex") |>
  separate_wider_delim(level,
                       delim = ".",
                       names = c("age", "sex")) |>
  mutate(age = reformat_age(age)) |> 
  ggplot(aes(x = age_mid(age),
             y = .fitted.mid)) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.5) +
  xlab("Age") +
  ylab("") +
  ggtitle("Age:sex interaction")

p_agesex <- p_age + p_agesex


p_time <- comp |>
  filter(component == "effect",
         term == "time") |>
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.5) +
  geom_vline(xintercept = end_date,
             linetype = "dashed") +
  scale_x_date(breaks = "1 year") +
  xlab("Time") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Time main effect")

p_time_trend <- comp |>
  filter(component == "trend",
         term == "time") |>
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.5) +
  geom_vline(xintercept = end_date,
             linetype = "dashed") +
  scale_x_date(breaks = "1 year") +
  xlab("Time") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Time main effect: Trend term")

p_time_error <- comp |>
  filter(component == "error",
         term == "time") |>
  ggplot(aes(x = as.Date(level),
             y = .fitted.mid)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.5) +
  geom_vline(xintercept = end_date,
             linetype = "dashed") +
  scale_x_date(breaks = "1 year") +
  xlab("Time") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Time main effect: Cyclical term")

p_agetime <- comp |>
  filter(component == "effect",
         term == "age:time") |>
  separate_wider_delim(level,
                       delim = ".",
                       names = c("age", "time")) |>
  mutate(age = reformat_age(age)) |>
  ggplot(aes(x = as.Date(time),
             y = .fitted.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.2) +
  geom_vline(xintercept = end_date,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Age:time interaction")

p_agetime_trend <- comp |>
  filter(component == "trend",
         term == "age:time") |>
  separate_wider_delim(level,
                       delim = ".",
                       names = c("age", "time")) |>
  mutate(age = reformat_age(age)) |>
  ggplot(aes(x = as.Date(time),
             y = .fitted.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.2) +
  geom_vline(xintercept = end_date,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Age:time interaction: Trend term")

p_agetime_season <- comp |>
  filter(component == "season",
         term == "age:time") |>
  separate_wider_delim(level,
                       delim = ".",
                       names = c("age", "time")) |>
  mutate(age = reformat_age(age)) |> 
  ggplot(aes(x = as.Date(time),
             y = .fitted.mid)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.2) +
  geom_vline(xintercept = end_date,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Age:time interaction: Season term")

p_sextime <- comp |>
  filter(component == "effect",
         term == "sex:time") |>
  separate_wider_delim(level,
                       delim = ".",
                       names = c("sex", "time")) |>
  ggplot(aes(x = as.Date(time),
             y = .fitted.mid)) +
  facet_wrap(vars(sex)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = alpha) +
  geom_line(color = col_line,
            linewidth = 0.2) +
  geom_vline(xintercept = end_date,
             linetype = "dashed") +
  xlab("Time") +
  ylab("") +
  ggtitle("Sex:time interaction")


## Linear predictor -----------------------------------------------------------

levels_age <- levels(aug$age)
plot_linpred <- function(level_age) {
  data <- filter(aug, age == level_age) |>
    mutate(linpred = log(.expected)) |>
    mutate(draws_ci(linpred))
  ggplot(data,
         aes(x = time,
             y = linpred.mid)) +
    facet_wrap(vars(sex), nrow = 2) +
    geom_ribbon(aes(ymin = linpred.lower,
                    ymax = linpred.upper),
                fill = col_fill,
                alpha = alpha) +
    geom_line(color = col_line,
              linewidth = 0.1) +
    geom_vline(xintercept = end_date,
               linetype = "dashed") +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Linear predictor (log scale)", subtitle = paste("Age", level_age))
}

p_linpred <- lapply(levels_age, plot_linpred)


## Mortality rates ------------------------------------------------------------

levels_age <- levels(aug$age)
plot_age_rates <- function(level_age) {
  data <- aug |>
    filter(age == level_age)
  ggplot(data,
         aes(x = time,
             y = .fitted.mid)) +
    facet_wrap(vars(sex), nrow = 2) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill,
                alpha = alpha) +
    geom_line(color = col_line,
              linewidth = 0.2) +
    geom_point(aes(y = .observed),
               col = col_point,
               size = 0.5) +
    geom_vline(xintercept = end_date,
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

p_lifeexp <- aug %>%
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
  geom_vline(xintercept = end_date,
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
plot(p_agesex)
plot(p_time)
plot(p_time_trend)
plot(p_time_error)
plot(p_agetime)
plot(p_agetime_trend)
plot(p_agetime_season)
plot(p_sextime)
for (p in p_linpred)
    plot(p)
for (p in p_age_rates)
    plot(p)
plot(p_lifeexp)
dev.off()        
