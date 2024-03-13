
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(deaths = "out/deaths.rds",
           exposure = "out/exposure.rds",
           start_date = "2010-01-01",
           end_date = "2020-02-01",
           .out = "out/sim.rds")

data <- inner_join(rename(deaths, deaths = count),
                   rename(exposure, exposure = count),
                   by = c("age", "sex", "time")) %>%
    mutate(time = paste0(time, "-15"),
           time = ymd(time)) %>%
    filter(time > ymd(start_date),
           time < ymd(end_date))


mod_est <- mod_pois(deaths ~ age * sex + time,
                    data = data,
                    exposure = exposure) %>%
    set_prior(age ~ RW()) %>%
    set_prior(age:sex ~ SVD(HMD)) %>%
    set_prior(time ~ RW2()) %>%
    set_cyclical(n = 3) %>%
    set_season(n = 12, by = age)


report <- report_sim(mod_est, n_sim = 1)

)

saveRDS(mod, file = .out)
