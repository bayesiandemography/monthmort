
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(ggplot2)
  library(command)
})


cmd_assign(.aug = "out/aug.rds",
           sex = "Female",
           end_date = as.Date("2020-01-31"),
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           col_point = "red",
           .out = "out/fig_paper_rates.pdf")

aug <- readRDS(.aug)

data <- aug |>
  filter(sex == !!sex) |>
  mutate(age = paste("Age", age),
         age = factor(age, levels = unique(age))) |>
  mutate(draws_ci(.fitted))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age),
             scale = "free_y",
             ncol = 3) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(aes(y = .fitted.mid),
            col = col_line,
            linewidth = 0.2) +
  geom_point(aes(y = .observed),
             col = col_point,
             size = 0.05,
             alpha = 0.6) +
  geom_vline(xintercept = end_date,
             linetype = "dashed",
             linewidth = 0.25) +
  scale_x_date(date_minor_breaks = "1 year") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  ylab("") +
  xlab("")

graphics.off()
pdf(file = .out,
    width = 6,
    height = 8)
plot(p)
dev.off()        


