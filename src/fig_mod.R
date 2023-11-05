
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)

cmd_assign(mod = "out/mod.rds",
           .out = "out/fig_mod.pdf")

## Extract results ------------------------------------------------------------

comp <- components(mod) %>%
    mutate(draws_ci(.fitted))

aug <- augment(mod) %>%
    mutate(draws_ci(.fitted))


## Settings -------------------------------------------------------------------

col_fill <- "lightblue2"

## Hyper-parameters -----------------------------------------------------------

p_age <- comp %>%
    filter(component == "par",
           term == "age") %>%
    ggplot(aes(x = age_mid(level),
               y = .fitted.mid)) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill) +
    geom_line(col = "darkblue",
              linewidth = 0.5) +
    xlab("Age") +
    ylab("") +
    ggtitle("Age effect")


p_agesex <- comp %>%
    filter(component == "par",
           term == "age:sex") %>%
    separate_wider_delim(level,
                         delim = ".",
                         names = c("age", "sex")) %>%
    ggplot(aes(x = age_mid(age),
               y = .fitted.mid)) +
    facet_wrap(vars(sex)) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill) +
    geom_line(col = "darkblue",
              linewidth = 0.5) +
    xlab("Age") +
    ylab("") +
    ggtitle("Age:sex effect")


p_time <- comp %>%
    filter(component == "par",
           term == "time") %>%
    ggplot(aes(x = as.Date(level),
               y = .fitted.mid)) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill) +
    geom_line(col = "darkblue",
              linewidth = 0.5) +
    scale_x_date(breaks = "1 year") +
    xlab("Time") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Time effect")


p_cyclical <- comp %>%
    filter(component == "cyclical",
           term == "par") %>%
    ggplot(aes(x = as.Date(level),
               y = .fitted.mid)) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill) +
    geom_line(col = "darkblue",
              linewidth = 0.5) +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Cyclical effect")


p_season <- comp %>%
    filter(component == "season",
           term == "par") %>%
    separate_wider_delim(level,
                         delim = ".",
                         names = c("age", "time")) %>%
    mutate(time = as.Date(time)) %>%
    mutate(age = reformat_age(age)) %>%
    ggplot(aes(x = time,
               y = .fitted.mid)) +
    facet_wrap(vars(age)) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill) +
    geom_line(col = "darkblue",
              linewidth = 0.1) +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Seasonal effect")


## Mortality rates ------------------------------------------------------------

levels_age <- levels(aug$age)
plot_age_rates <- function(level_age) {
    data <- filter(aug, age == level_age)
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
        scale_x_date(breaks = "1 year") +
        scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
        xlab("") +
        ylab("") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        ggtitle("Mortality rates", subtitle = paste("Age", level_age))
}

p_age_rates <- lapply(levels_age, plot_age_rates)


## Life expectancy ------------------------------------------------------------


p_lifeexp_actual <- aug %>%
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
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "top",
          legend.title = element_blank()) +
    ggtitle("Life expectancy")

p_lifeexp_seasonal <- aug %>%
    lifeexp(mx = .seasadj,
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
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "top",
          legend.title = element_blank()) +
    ggtitle("Life expectancy: Seasonally adjusted",
            subtitle = "Seasonal effect removed")

p_lifeexp_trend <- aug %>%
    lifeexp(mx = .trend,
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
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "top",
          legend.title = element_blank()) +
    ggtitle("Life expectancy: Underlying trend",
            subtitle = "Cyclical effect and seasonal effect removed")



## Print in one document ------------------------------------------------------

graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
plot(p_age)
plot(p_agesex)
plot(p_time)
plot(p_cyclical)
plot(p_season)
for (p in p_age_rates)
    plot(p)
plot(p_lifeexp_actual)
plot(p_lifeexp_seasonal)
plot(p_lifeexp_trend)
dev.off()        
