

library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
library(lubridate)

cmd_assign(mod = "out/mod.rds",
           .out = "out/fig_rates.pdf")

aug <- augment(mod)

col_fill <- "#FF7F50"
col_line <- "#2F4F4F"

data <- aug %>%
    filter(time == max(time)) %>%
    mutate(age = age_mid(age)) %>%
    mutate(draws_ci(.fitted))

p <- ggplot(data,
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
               col = "darkblue",
               size = 0.4) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    ylab("") +
    xlab("") +
    theme(text = element_text(size = 18))

graphics.off()
pdf(file = .out,
    width = 8,
    height = 5.5)
plot(p)
dev.off()        


