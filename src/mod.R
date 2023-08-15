
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(deaths = "out/deaths.rds",
           exposure = "out/exposure.rds",
           start_date = "2010-01-01",
           .out = "out/mod.rds")

data <- inner_join(rename(deaths, deaths = count),
                   rename(exposure, exposure = count),
                   by = c("age", "sex", "time")) %>%
    mutate(time = paste0(time, "-15"),
           time = ymd(time)) %>%
    filter(time > ymd(start_date))

mod <- mod_pois(deaths ~ age * sex + time,
                data = data,
                exposure = exposure) %>%
    set_prior(age ~ RW2()) %>%
    set_prior(time ~ RW2()) %>%
    set_season(n = 12, by = age) %>%
    fit()

saveRDS(mod, file = .out)
