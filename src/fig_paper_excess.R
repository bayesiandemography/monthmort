
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(.excess_deaths = "out/excess_deaths.rds",
           end_date = as.Date("2024-06-01"),
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_excess_pc.pdf")

excess_deaths <- readRDS(.excess_deaths)

data <- excess_deaths |>
  filter(age_lower(age) >= 50) |>
  mutate(age = (age_lower(age) %/% 10) * 10,
         age = ifelse(age < 90, paste(age, age + 9, sep = "-"), paste0(age, "+"))) |>
  group_by(age, time) |>
  summarise(expected = sum(expected),
            observed = sum(observed),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(excess = 100 * (observed - expected) / expected) |>
  mutate(draws_ci(excess)) |>
  filter(time <= end_date)


p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age), ncol = 2) +
  geom_hline(yintercept = 0,
             linewidth = 0.25) +
  geom_pointrange(aes(ymin = excess.lower,
                      y = excess.mid,
                      ymax = excess.upper),
                  linewidth = 0.15,
                  fatten = 0.5,
                  col = col_line) +
  ylim(-55, 55) +
  ylab("") + 
  xlab("")


graphics.off()
pdf(file = .out,
    w = 7,
    h = 8)
plot(p)
dev.off()
