
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
           .out = "out/fig_paper_calc_excess_panel.pdf")

excess <- readRDS(.excess)

data <- excess |>
  mutate(age = age_lower(age),
         age = 10 * (age %/% 10),
         age = case_when(age < 50 ~ "0-49",
                         age >= 50 & age < 90 ~ paste(age, age + 9, sep = "-"),
                         age >= 90 ~ "90+"),
         age = paste("Age", age)) |>
  count(age, time, wt = excess, name = "excess") |>
  mutate(draws_ci(excess))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age)) +
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
    height = 4)
plot(p)
dev.off()        


