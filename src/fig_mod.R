
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


## Hyper-parameters -----------------------------------------------------------

p_age <- comp %>%
    filter(component == "par",
           term == "age") %>%
    ggplot(aes(x = age_mid(level),
               ymin = .fitted.lower,
               y = .fitted.mid,
               ymax = .fitted.upper)) +
    geom_ribbon(fill = "lightgreen") +
    geom_line(col = "darkgreen",
              linewidth = 0.5) +
    ggtitle("Age effect")


p_agesex <- comp %>%
    filter(component == "par",
           term == "age:sex") %>%
    separate_wider_delim(level,
                         delim = ".",
                         names = c("age", "sex")) %>%
    mutate(age = reformat_age(age)) %>%
    ggplot(aes(x = age_mid(age),
               ymin = .fitted.lower,
               y = .fitted.mid,
               ymax = .fitted.upper)) +
    facet_wrap(vars(sex)) +
    geom_ribbon(fill = "lightgreen") +
    geom_line(col = "darkgreen",
              linewidth = 0.5) +
    ggtitle("Age:sex effect")


p_time <- comp %>%
    filter(component == "par",
           term == "time") %>%
    ggplot(aes(x = as.Date(level),
               ymin = .fitted.lower,
               y = .fitted.mid,
               ymax = .fitted.upper)) +
    geom_pointrange() +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Time effect")

p_season <- comp %>%
    filter(component == "season",
           term == "par") %>%
    separate_wider_delim(level,
                         delim = ".",
                         names = c("age", "time")) %>%
    mutate(time = as.Date(time)) %>%
    mutate(age = reformat_age(age)) %>%
    ggplot(aes(x = time,
               ymin = .fitted.lower,
               y = .fitted.mid,
               ymax = .fitted.upper)) +
    facet_wrap(vars(age)) +
    geom_ribbon(fill = "lightgreen") +
    geom_line(col = "darkgreen",
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
               ymin = .fitted.lower,
               y = .fitted.mid,
               ymax = .fitted.upper)) +
        facet_wrap(vars(sex), nrow = 2) +
        geom_ribbon(fill = "lightgreen") +
        geom_line(col = "darkgreen",
                  linewidth = 0.2) +
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

p_lifeexp <- aug %>%
    group_by(sex, time) %>%
    summarise(lifeexp = lifeexp(.fitted, age = age),
              .groups = "drop") %>%
    mutate(draws_ci(lifeexp)) %>%
    ggplot(aes(x = time,
               ymin = lifeexp.lower,
               y = lifeexp.mid,
               ymax = lifeexp.upper)) +
    facet_wrap(vars(sex), nrow = 2) +
    geom_ribbon(fill = "lightgreen") +
    geom_line(col = "darkgreen",
              linewidth = 0.2) +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Life expectancy")



## Print in one document ------------------------------------------------------

graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
plot(p_age)
plot(p_agesex)
plot(p_time)
plot(p_season)
for (p in p_age_rates)
    plot(p)
plot(p_lifeexp)
dev.off()        
