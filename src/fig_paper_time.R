
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(poputils)
  library(ggplot2)
})

cmd_assign(.comp = "out/comp.rds",
           end_date = as.Date("2020-01-31"),
           col_fill = "lightblue",
           col_line = "darkblue",
           .out = "out/fig_paper_time.pdf")

comp <- readRDS(.comp)

time <- comp |>
  filter(term == "time", component != "hyper") |>
  select(component, time = level, .fitted) |>
  mutate(time = as.Date(time)) |>
  mutate(draws_ci(.fitted)) |>
  mutate(component = factor(component,
                            levels = c("effect", "trend", "error"),
                            labels = c("Effect", "Trend", "Cyclical")))

p <- ggplot(time, aes(x = time)) +
  facet_wrap(vars(component), ncol = 1) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(aes(y = .fitted.mid),
            color = col_line,
            linewidth = 0.2) +
  geom_vline(xintercept = end_date,
             linewidth = 0.25,
             linetype = "dotted") +
  scale_x_date(date_minor_breaks = "1 year") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  xlab("") +
  ylab("")


graphics.off()
pdf(file = .out,
    width = 5,
    height = 6)
plot(p)
dev.off()
