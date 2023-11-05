
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(readr)
library(ggplot2)

cmd_assign(mod = "out/mod.rds",
           .out = "out/point_est_time.csv")

comp <- components(mod)

point_est_time <- comp %>%
    filter(component == "par",
           term == "time") %>%
    mutate(value = draws_median(.fitted)) %>%
    select(time = level, value)


write_csv(point_est_time, file = .out)

