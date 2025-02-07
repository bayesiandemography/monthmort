
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(lubridate)
  library(ggplot2)
  library(command)
})

cmd_assign(excess = "out/excess.rds",
           col_fill = "lightblue",
           col_line = "darkblue",
           .out = "out/fig_paper_calc_excess_panel.pdf")

excess <- excess |>
  filter(time < as.Date("2024-06-01")) ## TEMPORARY FIX - DEATHS MISSING FOR LAST MONTH

data <- excess |>
  filter(age_lower(age) >= 60) |>
  mutate(age = age_lower(age),
         age = 10 * (age %/% 10),
         age = case_when(age < 90 ~ paste(age, age + 9, sep = "-"),
                         age >= 90 ~ "90+"),
         age = paste("Age", age)) |>
  count(age, time, wt = excess, name = "excess") |>
  mutate(draws_ci(excess))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age), nrow = 1) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            col = col_line) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  ylab("") +
  xlab("") +
  theme(text = element_text(size = 10))

graphics.off()
pdf(file = .out,
    width = 6,
    height = 3)
plot(p)
dev.off()        


