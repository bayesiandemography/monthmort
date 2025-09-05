
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(ggplot2)
  library(command)
})

cmd_assign(.excess_ag = "out/excess_ag.rds",
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_excess_ag.pdf")

excess_ag <- readRDS(.excess_ag)

data <- excess_ag |>
  mutate(draws_ci(excess))

p <- ggplot(data, aes(x = time)) +
  facet_grid(vars(sex), vars(age)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            col = col_line,
            linewidth = 0.25) +
  geom_hline(yintercept = 0,
             linewidth = 0.25) +
  ylab("Deaths") +
  xlab("") +
  theme(text = element_text(size = 10))

pdf(file = .out,
    width = 6,
    height = 3.5)
plot(p)
dev.off()        


