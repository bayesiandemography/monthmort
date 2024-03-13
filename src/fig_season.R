

library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
library(lubridate)

cmd_assign(mod = "out/mod.rds",
           .out = "out/fig_season.pdf")

col_fill <- "#FF7F50"
col_line <- "#2F4F4F"

comp <- components(mod)

data <- comp %>%
    filter(component == "season",
           term == "effect") %>%
    separate(level, into = c("age", "time"), sep = "\\.") %>%
    mutate(component = "trend") %>%
    select(-term) %>%
    filter(age %in% c("10-14", "40-44", "95+")) %>%
    mutate(time = as.Date(time)) %>%
    mutate(draws_ci(.fitted))

p <- ggplot(data,
       aes(x = time,
           y = .fitted.mid)) +
    facet_wrap(vars(age),
               ncol = 1) +
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
    theme(text = element_text(size = 18))

graphics.off()
pdf(file = .out,
    width = 6,
    height = 6)
plot(p)
dev.off()        


