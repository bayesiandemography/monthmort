
suppressPackageStartupMessages({
  library(dplyr)
  library(poputils)
  library(readr)
  library(lubridate)
  library(rvec)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           .out = "out/tab_excess_total.csv")

excess <- readRDS(.excess)

make_str <- function(x) {
  sprintf("%1.0f (%1.0f, %1.0f)",
          draws_median(x),
          draws_quantile(x, 0.025)[[1]],
          draws_quantile(x, 0.975)[[1]])
}

tab_excess_total <- excess |>
  filter(time < as.Date("2025-01-01")) |>
  mutate(year = year(time)) |>
  count(year, wt = excess, name = "annual") |>
  mutate(cumulative = cumsum(annual)) |>
  mutate(annual = make_str(annual),
         cumulative = make_str(cumulative))


write_csv(tab_excess_total, file = .out)

