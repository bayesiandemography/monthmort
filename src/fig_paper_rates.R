
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(lubridate)
  library(ggplot2)
  library(command)
})


cmd_assign(aug = "out/aug.rds",
           end_date = "2020-01-31",
           col_fill = "lightblue",
           col_line = "darkblue",
           col_point = "red",
           .out = "out/fig_paper_rates.pdf")

end_date <- ymd(end_date)

ages_show <- c("40-44", "75-79", "90-94")

data <- aug |>
  filter(age %in% ages_show) |>
  mutate(age = paste("Age", age)) |>
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
             size = 0.2) +
  geom_vline(xintercept = end_date,
             linetype = "dashed",
             linewidth = 0.25) +
  scale_x_date(date_minor_breaks = "1 year") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  ylab("") +
  xlab("")

graphics.off()
pdf(file = .out,
    width = 7,
    height = 5)
plot(p)
dev.off()        


