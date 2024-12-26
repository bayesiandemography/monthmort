
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(tidyr)
  library(command)
})

cmd_assign(excess_deaths = "out/excess_deaths.rds",
           end_date = "2024-06-01",
           col_line = "darkblue",
           .out = "out/fig_diff_lifeexp.pdf")

end_date <- as.Date(end_date)

excess_deaths <- excess_deaths |>
  filter(time <= end_date)

data_expected_0 <- excess_deaths |>
  mutate(mx = expected / exposure) |>
  lifeexp(mx = mx,
          sex = sex,
          by = time) |>
  mutate(variant = "expected",
         at = "Age 0")

data_observed_0 <- excess_deaths |>
  mutate(mx = observed / exposure) |>
  lifeexp(mx = mx,
          sex = sex,
          by = time) |>
  mutate(variant = "observed",
         at = "Age 0")

data_expected_65 <- excess_deaths |>
  mutate(mx = expected / exposure) |>
  lifeexp(mx = mx,
          sex = sex,
          by = time,
          at = 65) |>
  mutate(variant = "expected",
         at = "Age 65")

data_observed_65 <- excess_deaths |>
  mutate(mx = observed / exposure) |>
  lifeexp(mx = mx,
          sex = sex,
          by = time,
          at = 65) |>
  mutate(variant = "observed",
         at = "Age 65")

data <- bind_rows(data_expected_0,
                  data_observed_0,
                  data_expected_65,
                  data_observed_65) |>
  pivot_wider(names_from = variant, values_from = ex) |>
  mutate(excess = observed - expected) |>
  mutate(draws_ci(excess))
  

p <- ggplot(data, aes(x = time, y = excess)) +
  facet_grid(vars(sex), vars(at)) +
  geom_hline(yintercept = 0,
             linewidth = 0.25) +
  geom_pointrange(aes(ymin = excess.lower,
                      y = excess.mid,
                      ymax = excess.upper),
                  linewidth = 0.15,
                  fatten = 0.5,
                  col = col_line) +
  ylab("") + 
  xlab("")


graphics.off()
pdf(file = .out,
    w = 7,
    h = 5)
plot(p)
dev.off()
