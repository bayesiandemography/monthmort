
suppressPackageStartupMessages({
  library(dplyr)
  library(poputils)
  library(readr)
  library(lubridate)
  library(rvec)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           .out = "out/tab_excess.rds")

excess <- readRDS(.excess)

make_str <- function(x) {
  nm <- deparse(substitute(x))
  ans <- data.frame(pt = formatC(draws_median(x),
                                 digits = 0,
                                 big.mark = ",",
                                 format = "f"),
                    ci = sprintf("(%s, %s)",
                                 formatC(draws_quantile(x, 0.025)[[1]],
                                         digits = 0,
                                         big.mark = ",",
                                         format = "f"),
                                 formatC(draws_quantile(x, 0.975)[[1]],
                                         digits = 0,
                                         big.mark = ",",
                                         format = "f")))
  names(ans) <- paste(nm, names(ans), sep = ".")
  ans
}

tab_excess <- excess |>
  filter(time < as.Date("2025-01-01")) |>
  mutate(Year = year(time)) |>
  mutate(Year <= 2024) |>
  count(Year, wt = excess, name = "Annual") |>
  mutate(Cumulative = cumsum(Annual)) |>
  mutate(make_str(Annual)) |>
  mutate(make_str(Cumulative)) |>
  select(-c(Annual, Cumulative))

saveRDS(tab_excess, file = .out)

