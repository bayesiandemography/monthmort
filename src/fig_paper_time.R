
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(poputils)
  library(ggplot2)
})

cmd_assign(.comp = "out/comp.rds",
           end_date = as.Date("2020-01-31"),
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
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

hline_df <- data.frame(component = factor(c("Effect", "Trend" ,"Cyclical"),
                                          levels = c("Effect", "Trend", "Cyclical")),
                       yintercept = c(NA, NA, 0))

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
             linetype = "dashed") +
  scale_x_date(breaks = seq(from = as.Date("2000-01-01"),
                            to = as.Date("2025-01-01"),
                            by = "5 years"),
               date_minor_breaks = "1 year",
               date_labels = "%Y") +
  geom_hline(data = hline_df,
             aes(yintercept = yintercept),
             linewidth = 0.2) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE),
                     limits = c(-0.4, 0.4)) +
  xlab("") +
  ylab("")

pdf(file = .out,
    width = 5,
    height = 6.5)
plot(p)
dev.off()
