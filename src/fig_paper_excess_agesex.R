
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(lubridate)
  library(ggplot2)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           sex = "Female",
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_paper_excess_agesex_female.pdf")

excess <- readRDS(.excess)

data <- excess |>
  filter(sex == !!sex) |>
  mutate(excess = excess / 1000) |>
  mutate(draws_ci(excess))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            color = col_line,
            linewidth = 0.25) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  ylim(-0.105, 0.156) + ## taken from results for females
  ylab("Deaths (000)") +
  xlab("")

graphics.off()
pdf(file = .out,
    width = 6,
    height = 7.5)
plot(p)
dev.off()        


