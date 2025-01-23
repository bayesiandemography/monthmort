
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(data = "out/data.rds",
           forecast = "out/forecast.rds",
           end_date = "2024-01-01",
           col_fill = "lightblue",
           col_line = "darkblue",
           col_point = "red",
           .out = "out/fig_excess_age.pdf")

end_date <- as.Date(end_date)

expected <- forecast |>
  count(age, time, wt = .deaths, name = "expected")

observed <- data |>
  count(age, time, wt = deaths, name = "observed")

data <- inner_join(expected, observed, by = c("age", "time")) |>
  filter(time <= end_date) |>
  mutate(excess = observed - expected) |>
  mutate(age = (age_lower(age) %/% 10) * 10,
         age = ifelse(age < 90, paste(age, age + 9, sep = "-"), paste0(age, "+"))) |>
  mutate(year = format(time, "%Y")) |>
  count(age, year, wt = excess, name = "excess") |>
  group_by(age) |>
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
    w = 4,
    h = 5)
plot(p)
dev.off()
