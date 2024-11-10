
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(data = "out/data.rds",
           forecast = "out/forecast.rds",
           col_fill = "lightblue",
           col_line = "darkblue",
           col_point = "red",
           .out = "out/fig_excess_age.pdf")

expected <- forecast |>
  count(age, time, wt = .deaths, name = "expected")

observed <- data |>
  filter(time %in% expected$time) |>
  count(age, time, wt = deaths, name = "observed")

data <- inner_join(expected, observed, by = c("age", "time")) |>
  mutate(excess = observed - expected) |>
  mutate(age = (age_lower(age) %/% 10) * 10,
         age = ifelse(age < 90, paste(age, age + 9, sep = "-"), paste0(age, "+"))) |>
  mutate(year = format(time, "%Y")) |>
  count(age, year, wt = excess, name = "excess") |>
  group_by(age) |>
  mutate(excess = cumsum(excess)) |>
  ungroup() |>
  expand_from_rvec()
  

p <- ggplot(data, aes(x = year, y = excess)) +
  facet_wrap(vars(age), ncol = 5) +
  geom_hline(yintercept = 0,
             linewidth = 0.25) +
  geom_boxplot(outliers = FALSE,
               color = col_line,
               fill = col_fill,
               linewidth = 0.25) +
  ylim(-2000, 2000) +
  ylab("") + 
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

graphics.off()
pdf(file = .out,
    w = 5,
    h = 6.5)
plot(p)
dev.off()
