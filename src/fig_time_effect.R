
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(poputils)
  library(ggplot2)
})

cmd_assign(comp = "out/comp_all.rds",
           col_line = "darkblue",
           col_fill = "lightblue",
           .out = "out/fig_time_effect.pdf")

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
  geom_vline(xintercept = as.Date("2020-02-15"),
             linewidth = 0.2,
             linetype = "dotted") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  scale_x_date(breaks = "1 year") +
  xlab("") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

graphics.off()
pdf(file = .out,
    width = 8,
    height = 10)
plot(p)
dev.off()
