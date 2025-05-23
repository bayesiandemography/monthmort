
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(lubridate)
  library(ggplot2)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_paper_excess_ag.pdf")

excess <- readRDS(.excess)

data <- excess |>
  mutate(age = age_lower(age),
         age = 10 * (age %/% 10),
         age = case_when(age < 50 ~ "0-49",
                         age >= 50 & age < 90 ~ paste(age, age + 9, sep = "-"),
                         age >= 90 ~ "90+"),
         age = paste("Age", age)) |>
  count(age, sex, time, wt = excess, name = "excess") |>
  mutate(excess = excess / 1000) |>
  mutate(draws_ci(excess))

p <- ggplot(data, aes(x = time)) +
  facet_grid(vars(sex), vars(age)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            col = col_line) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  ylab("Deaths (000)") +
  xlab("") +
  theme(text = element_text(size = 10))

pdf(file = .out,
    width = 6,
    height = 5)
plot(p)
dev.off()        


