
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(rvec)
  library(ggplot2)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_paper_calc_excess_all.pdf")

excess <- readRDS(.excess)

data <- excess |>
  group_by(time) |>
  summarise(expected = sum(expected),
            observed = sum(observed),
            excess = sum(excess)) |>
  pivot_longer(c(expected, observed, excess), names_to = "series") |>
  mutate(series = factor(series,
                         levels = c("observed", "expected", "excess"),
                         labels = c("Observed", "Expected", "Excess"))) |>
  mutate(value = value / 1000) |>
  mutate(draws_ci(value))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(series)) +
  geom_ribbon(aes(ymin = value.lower,
                  ymax = value.upper),
              fill = col_fill) +
  geom_line(aes(y = value.mid),
            col = col_line) +
  geom_hline(yintercept = 0,
             linewidth = 0.25) +
  ylim(-0.75, 4.25) +
  ylab("Deaths (000)") +
  xlab("")

graphics.off()
pdf(file = .out,
    width = 6,
    height = 3)
plot(p)
dev.off()        


