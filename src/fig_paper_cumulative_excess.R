
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(lubridate)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(excess = "out/excess.rds",
           col_fill = "lightblue",
           col_line = "darkblue",
           .out = "out/fig_paper_cumulative_excess.pdf")

data <- excess |>
  mutate(age = age_lower(age),
         age = 10 * (age %/% 10),
         age = case_when(age < 50 ~ "0-49",
                         age >= 50 & age < 90 ~ paste(age, age + 9, sep = "-"),
                         age >= 90 ~ "90+"),
         age = paste("Age", age)) |>
  count(age, time, wt = excess, name = "excess") |>
  group_by(age) |>
  mutate(cumexcess = cumsum(excess)) |>
  ungroup() |>
  mutate(draws_ci(cumexcess))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymax = cumexcess.upper,
                  ymin = cumexcess.lower),
              fill = col_fill) +
  geom_line(aes(y = cumexcess.mid),
           col = col_line) +
  geom_hline(yintercept = 0,
             color = "grey20",
             linewidth = 0.2) +
  ylab("") +
  xlab("") +
  theme(legend.position = "none")


graphics.off()
pdf(file = .out,
    width = 6,
    height = 4)
plot(p)
dev.off()        


