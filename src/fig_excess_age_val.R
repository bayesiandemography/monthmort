
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(ggplot2)
  library(command)
})

cmd_assign(.excess_age = "out/excess_age.rds",
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_excess_age_val.pdf")

excess_age <- readRDS(.excess_age)

data <- excess_age |>
  mutate(draws_ci(excess))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age), nrow = 1) +
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
    height = 2)
plot(p)
dev.off()        


