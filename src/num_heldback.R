
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(command)
})

cmd_assign(.vals = "out/vals_heldback.rds",
           .out = "out/num_heldback.csv")

vals <- readRDS(.vals)

num_inside <- vals |>
  mutate(is_inside = (deaths_forecast.lower <= deaths_true) &
           (deaths_true <= deaths_forecast.upper)) |>
  pull(is_inside) |>
  sum()

num_tests <- vals |>
  nrow()

num <- data.frame(num_tests = num_tests,
                  num_inside = num_inside,
                  propn_inside = num_inside / num_tests)

write_csv(num, file = .out)
