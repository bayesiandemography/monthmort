
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
           .out = "out/fig_excess_agesex_female.pdf")

excess <- readRDS(.excess)

data <- excess |>
  filter(sex == !!sex) |>
  mutate(draws_ci(excess))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age), ncol = 7) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            color = col_line,
            linewidth = 0.25) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  ylim(-105, 156) + ## taken from results for females
  ylab("Deaths") +
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

pdf(file = .out,
    width = 6,
    height = 8)
plot(p)
dev.off()        


