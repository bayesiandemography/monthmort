
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(ggplot2)
library(tidyr)

cmd_assign(mod = "../out/mod.rds",
           .out = "fig_season.pdf")

levels_age <- c("45-49", "90-94")

comp <- components(mod)

data <- comp %>%
    filter(component == "season",
           term == "par") %>%
    separate_wider_delim(level,
                         delim = ".",
                         names = c("age", "time")) %>%
    mutate(time = as.Date(time)) %>%
    mutate(age = reformat_age(age)) %>%
    filter(age %in% levels_age) %>%
    mutate(draws_ci(.fitted))

p <-ggplot(data, aes(x = time,
                     ymin = .fitted.lower,
                     y = .fitted.mid,
                     ymax = .fitted.upper)) +
    facet_wrap(vars(age), ncol = 1) +
    geom_ribbon(fill = "lightblue") +
    geom_line(col = "darkblue",
              linewidth = 0.1) +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))

graphics.off()
pdf(file = .out,
    width = 7,
    height = 5)
plot(p)
dev.off()
    

