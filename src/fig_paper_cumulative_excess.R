
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(lubridate)
  library(ggplot2)
  library(command)
})

cmd_assign(excess = "out/excess.rds",
           col_line = "darkblue",
           .out = "out/fig_paper_cumulative_excess.pdf")

excess <- excess |>
  filter(time < as.Date("2024-06-01")) ## TEMPORARY FIX - DEATHS MISSING FOR LAST MONTH

data <- excess |>
  count(time, wt = excess, name = "excess") |>
  mutate(cumexcess = cumsum(excess)) |>
  mutate(draws_ci(cumexcess))

p <- ggplot(data, aes(x = time)) +
  geom_hline(yintercept = 0,
             color = "grey") +
  geom_errorbar(aes(ymax = cumexcess.upper,
                    ymin = cumexcess.lower),
                color = col_line) +
  geom_point(aes(y = cumexcess.mid),
             col = col_line) +
  ylab("") +
  xlab("") +
  theme(legend.position = "none")


graphics.off()
pdf(file = .out,
    width = 5,
    height = 3)
plot(p)
dev.off()        


