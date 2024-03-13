

library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
library(lubridate)

cmd_assign(mod = "out/mod.rds",
           .out = "out/fig_time.pdf")

col_fill <- "#FF7F50"
col_line <- "#2F4F4F"

comp <- components(mod)

trend <- comp %>%
    filter(component == "effect",
           term == "time") %>%
    mutate(component = "trend") %>%
    select(-term)
cyclical <- comp %>%
    filter(component == "cyclical",
           term == "effect") %>%
    select(-term)
    
data <- bind_rows(trend, cyclical) %>%
    pivot_wider(names_from = component, values_from = .fitted) %>%
    mutate(effect = trend + cyclical) %>%
    pivot_longer(c(effect, trend, cyclical), names_to = "component", values_to = ".fitted") %>%
    mutate(component = factor(component,
                              levels = c("effect", "trend", "cyclical"),
                              labels = c("Time Effect", "Trend Component", "Cyclical Component"))) %>%
    mutate(level = as.Date(level)) %>%
    mutate(draws_ci(.fitted))

p <- ggplot(data,
       aes(x = level,
           y = .fitted.mid)) +
    facet_wrap(vars(component),
               ncol = 1) +
    geom_ribbon(aes(ymin = .fitted.lower,
                    ymax = .fitted.upper),
                fill = col_fill,
                alpha = 0.5) +
    geom_line(col = col_line,
              linewidth = 0.25) +
    scale_x_date(breaks = "1 year",
                 date_labels = "%Y") +
    ylim(-0.15, 0.15) +
    ylab("") +
    xlab("") +
    theme(text = element_text(size = 18))

graphics.off()
pdf(file = .out,
    width = 6,
    height = 6)
plot(p)
dev.off()        
