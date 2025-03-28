
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(poputils)
  library(lubridate)
  library(ggplot2)
})

cmd_assign(comp = "out/comp_all.rds",
           end_date = "2020-01-31",
           col_fill = "lightblue",
           col_line = "darkblue",
           .out = "out/fig_paper_cyclical_all.pdf")

end_date <- ymd(end_date)

data <- comp |>
  filter(term == "time", component == "error") |>
  mutate(time = ymd(level)) |>
  mutate(draws_ci(.fitted))

max_abs <- max(abs(c(data$.fitted.lower, data$.fitted.upper)))

p <- ggplot(data, aes(x = time)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(aes(y = .fitted.mid),
            color = col_line,
            linewidth = 0.25) +
  geom_vline(xintercept = end_date,
             linewidth = 0.25,
             linetype = "dashed") +
  geom_hline(yintercept = 0,
             linewidth = 0.25,
             col = "grey40") +
  scale_x_date(date_minor_breaks = "1 year") +
  ylim(-max_abs, max_abs) +
  xlab("") +
  ylab("")


graphics.off()
pdf(file = .out,
    width = 7.5,
    height = 3)
plot(p)
dev.off()
