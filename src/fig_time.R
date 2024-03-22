
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec, warn.conflicts = FALSE)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(mod = "out/mod.rds",
           col_fill = "steelblue1",
           col_line = "black",
           .out = "out/fig_time.pdf")

comp <- components(mod)

data <- comp %>%
  filter(term == "time",
         component != "hyper") %>%
  mutate(component = factor(component,
                            levels = c("effect", "trend", "cyclical"),
                            labels = c("Time Effect", "Trend Component", "Cyclical Component"))) %>%
  mutate(level = as.Date(level)) %>%
  mutate(draws_ci(.fitted))

y_abs_max <- data %>%
  select(.fitted.lower, .fitted.upper) %>%
  unlist() %>%
  abs() %>%
  max()

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
    ylim(-y_abs_max, y_abs_max) +
    ylab("") +
    xlab("") +
    theme(text = element_text(size = 18))

graphics.off()
pdf(file = .out,
    width = 6,
    height = 6)
plot(p)
dev.off()        
