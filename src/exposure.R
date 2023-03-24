
library(readr)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(zoo)
library(lubridate, warn.conflicts = FALSE)
library(poputils)
library(command)

cmd_assign(deaths = "out/deaths.rds",
           popn = "out/popn.rds",
           .out = "out/exposure.rds")

month_min <- deaths %>% pull(time) %>% min()
month_max <- deaths %>% pull(time) %>% max()

exposure <- popn %>%
    mutate(time = sub("Q1$", "-03-31", time),
           time = sub("Q2$", "-06-30", time),
           time = sub("Q3$", "-09-30", time),
           time = sub("Q4$", "-12-31", time)) %>%
    mutate(time = ymd(time)) %>%
    mutate(time = factor(as.character(time),
                         levels = as.character(seq(from = min(time + 1),
                                                   to = max(time + 1),
                                                   by = "month") - 1L))) %>%
    complete(time, sex, age, fill = list(count = NA)) %>%
    mutate(time = ymd(as.character(time))) %>%
    group_by(age, sex) %>%
    arrange(time) %>%
    mutate(count = na.spline(count)) %>%
    mutate(mean_val = 0.5 * (count + lag(count))) %>%
    mutate(n_day = as.integer(time - lag(time))) %>%
    ungroup() %>%
    mutate(count = (n_day / 365.25) * mean_val) %>%
    select(age, sex, time, count) %>%
    mutate(time = format(time, "%Y-%m")) %>%
    filter(time >= month_min,
           time <= month_max)

saveRDS(exposure, file = .out)

           

    

