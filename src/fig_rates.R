
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(ggplot2)
  library(command)
})


cmd_assign(.aug = "out/aug.rds",
           .example_ages = "out/example_ages.rds",
           end_date = as.Date("2020-01-31"),
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           col_point = "red",
           .out = "out/fig_rates.pdf")

aug <- readRDS(.aug)
example_ages <- readRDS(.example_ages)

data <- aug |>
  filter(age %in% example_ages) |>
  mutate(age = paste("Age", age),
         age = factor(age, levels = unique(age))) |>
  mutate(draws_ci(.fitted))

p <- ggplot(data, aes(x = time)) +
  facet_grid(vars(age), vars(sex), scale = "free_y") +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(aes(y = .fitted.mid),
            col = col_line,
            linewidth = 0.4) +
  geom_point(aes(y = .observed),
             col = col_point,
             size = 0.05) +
  geom_vline(xintercept = end_date,
             linetype = "dashed",
             linewidth = 0.25) +
  scale_x_date(breaks = seq.Date(from = as.Date("2000-01-01"),
                                 to = as.Date("2025-01-01"),
                                 by = "5 year"),
               date_minor_breaks = "1 year",
               date_labels = "%Y") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE),
                     limits = c(0, NA)) +
  ylab("") +
  xlab("")

pdf(file = .out,
    width = 6,
    height = 7)
plot(p)
dev.off()        


