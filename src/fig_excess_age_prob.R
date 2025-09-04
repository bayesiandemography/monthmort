
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(ggplot2)
  library(command)
})

cmd_assign(.excess_age = "out/excess_age.rds",
           .out = "out/fig_excess_age_prob.pdf")

excess_age <- readRDS(.excess_age)

data <- excess_age |>
  mutate(gt0 = draws_mean(excess > 0))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age), nrow = 1) +
  geom_hline(yintercept = 0.5,
             linetype = "dotted") +
  geom_line(aes(y = gt0, x = time),
            linewidth = 0.25) +
  scale_y_continuous(breaks = seq(0, 1, 0.2),
                     minor_breaks = seq(0, 1, 0.1),
                     limits = c(0, 1),
                     expand = c(0, 0)) +
  xlab("") +
  ylab("Probability") +
  theme(text = element_text(size = 10))

pdf(file = .out,
    width = 6,
    height = 2)
plot(p)
dev.off()        


