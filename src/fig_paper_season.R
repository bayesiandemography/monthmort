
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
           .example_ages = "out/example_ages.rds",
           use_example_ages = TRUE,
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_paper_season.pdf")

comp <- readRDS(.comp)
example_ages <- readRDS(.example_ages)

season <- comp |>
  filter(component == "season") |>
  separate_wider_delim(level, delim = ".", names = c("age", "time")) |>
  mutate(time = ymd(time)) |>
  filter(year(time) %in% 2000) |> ## effects constant across years
  mutate(time = month(time),
         time = as.integer(time))

if (use_example_ages) {
  season <- season |>
    filter(age %in% example_ages)
}

season <- season |>
  mutate(age = paste("Age", age),
         age = factor(age, levels = unique(age))) |>
  mutate(draws_ci(.fitted))

p <- ggplot(season, aes(x = time)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(aes(y = .fitted.mid),
            color = col_line,
            linewidth = 0.2) +
  scale_x_continuous(breaks = c(1, 4, 7, 10),
                     minor_breaks = 1:12,
                     labels = c("Jan", "Apr", "Jul", "Oct")) +
  xlab("") +
  ylab("") +
  theme(axis.text.x = element_text(size = 8),
        axis.text.y = element_text(size = 8))

if (use_example_ages) {
  p <- p + facet_wrap(vars(age), nrow = 1)
} else {
  p <- p + facet_wrap(vars(age), ncol = 7)
}


graphics.off()
pdf(file = .out,
    width = 6,
    height = if (use_example_ages) 2.7 else 8)
plot(p)
dev.off()
