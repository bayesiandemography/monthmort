
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(zoo)
  library(lubridate)
  library(poputils)
  library(command)
})

cmd_assign(.popn = "out/popn.rds",
           .out = "out/exposure.rds")

popn <- readRDS(.popn)

exposure <- popn %>%
  mutate(time = sub("Q1$", "-03-31", time),
         time = sub("Q2$", "-06-30", time),
         time = sub("Q3$", "-09-30", time),
         time = sub("Q4$", "-12-31", time)) |>
  mutate(time = ymd(time)) |>
  mutate(time = factor(as.character(time),
                       levels = as.character(seq(from = min(time + 1),
                                                 to = max(time + 1),
                                                 by = "month") - 1L))) |>
  complete(time, sex, age, fill = list(popn = NA)) |>
  mutate(time = ymd(as.character(time))) %>%
  group_by(age, sex) %>%
  arrange(time) %>%
  mutate(popn = na.spline(popn)) |>
  mutate(mean_val = 0.5 * (popn + lag(popn))) |>
  mutate(n_day = as.integer(time - lag(time))) |>
  ungroup() |>
  mutate(exposure = (n_day / 365.25) * mean_val) |>
  select(age, sex, time, exposure) |>
  mutate(time = format(time, "%Y-%m"),
         time = paste0(time, "-15"),
         time = ymd(time)) |>
  filter(!is.na(exposure))

saveRDS(exposure, file = .out)

           

    

