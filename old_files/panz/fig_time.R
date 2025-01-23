
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(ggplot2)
library(tidyr)

cmd_assign(mod = "../out/mod.rds",
           .out = "fig_time.pdf")

comp <- components(mod)

data <- comp %>%
    filter(component == "par",
           term == "time") %>%
    mutate(time = as.Date(level)) %>%
    mutate(draws_ci(.fitted))

p <-ggplot(data, aes(x = time,
                     ymin = .fitted.lower,
                     y = .fitted.mid,
                     ymax = .fitted.upper)) +
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
    

