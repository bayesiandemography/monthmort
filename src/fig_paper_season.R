
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(lubridate)
  library(ggplot2)
  library(command)
})

cmd_assign(.comp = "out/comp.rds",
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_paper_season.pdf")

comp <- readRDS(.comp)

season <- comp |>
  filter(component == "season") |>
  separate_wider_delim(level, delim = ".", names = c("age", "time")) |>
  mutate(time = ymd(time)) |>
  filter(year(time) %in% 2000) |> ## effects constant across years
  mutate(time = month(time),
         time = as.integer(time)) |>
  filter(age %in% c("10-14", "40-44", "70-74", "90-94")) |>
  mutate(age = paste("Age", age)) |>
  mutate(draws_ci(.fitted))

p <- ggplot(season, aes(x = time)) +
  facet_wrap(vars(age), nrow = 1) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(aes(y = .fitted.mid),
            color = col_line,
            linewidth = 0.2) +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  xlab("") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  

graphics.off()
pdf(file = .out,
    width = 6,
    height = 2.2)
plot(p)
dev.off()
