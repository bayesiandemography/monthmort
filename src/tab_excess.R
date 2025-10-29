
suppressPackageStartupMessages({
  library(dplyr)
  library(poputils)
  library(readr)
  library(lubridate)
  library(rvec)
  library(xtable)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           .out = "out/tab_excess.tex")

excess <- readRDS(.excess)

make_str <- function(x) {
  nm <- deparse(substitute(x))
  ans <- data.frame(pt = formatC(draws_median(x),
                                 digits = 1,
                                 format = "f"),
                    ci = sprintf("(%s, %s)",
                                 formatC(draws_quantile(x, 0.025)[[1]],
                                         digits = 1,
                                         format = "f"),
                                 formatC(draws_quantile(x, 0.975)[[1]],
                                         digits = 1,
                                         format = "f")))
  names(ans) <- paste(nm, names(ans), sep = ".")
  ans
}

tab_excess <- excess |>
  filter(time < as.Date("2025-01-01")) |>
  mutate(Year = year(time)) |>
  mutate(Year <= 2024) |>
  mutate(excess = excess / 1000) |>
  count(Year, wt = excess, name = "Annual") |>
  mutate(Cumulative = cumsum(Annual)) |>
  mutate(make_str(Annual)) |>
  mutate(make_str(Cumulative)) |>
  select(-c(Annual, Cumulative))

names(tab_excess)[-1] <- c("Annual", "(95\\% CI)", "Cumulative", "(95\\% CI)")

tab_excess |>
  xtable(caption = "Annual and cumulative excess deaths (thousands)",
         label = "tab:annual_cumulative",
         align = "llrrrr",
         digits = 0) |>
  print(file = .out,
        include.rownames = FALSE,
        sanitize.text.function = identity,
        caption.placement = "top")

