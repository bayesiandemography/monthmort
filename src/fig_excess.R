
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(excess_deaths = "out/excess_deaths.rds",
           col_fill = "lightblue",
           col_line = "darkblue",
           .out = "out/aug.rds")

data <- excess_deaths |>
  mutate(age = (age_lower(age) %/% 10) * 10,
         age = ifelse(age < 90, paste(age, age + 9, sep = "-"), paste0(age, "+"))) |>
  mutate(year = format(time, "%Y")) |>
  count(age, year, wt = excess, name = "excess") |>
  group_by(age, excess = cumsum(excess)) |>
  expand_from_rvec()

p <- ggplot(data_abs, aes(x = year, y = excess)) +
  facet_wrap(vars(age), nrow = 1) +
  geom_hline(yintercept = 0,
             linetype = "dotted",
             linewidth = 0.2) +
  geom_boxplot(outliers = FALSE,
               color = col_line,
               fill = col_fill,
               linewidth = 0.25) +
  ylim(-2000, 2000) +
  ylab("") + 
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

graphics.off()
pdf(
plot(p)
