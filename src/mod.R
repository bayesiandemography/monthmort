
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(deaths = "out/deaths.rds",
           exposure = "out/exposure.rds",
           start_date = "2010-02-01",
           end_date = "2020-02-01",
           .out = "out/mod.rds")

data <- inner_join(rename(deaths, deaths = count),
                   rename(exposure, exposure = count),
                   by = c("age", "sex", "time")) |>
    mutate(time = paste0(time, "-15"),
           time = ymd(time)) |>
    filter(time > ymd(start_date),
           time < ymd(end_date))

system.time(
  mod <- mod_pois(deaths ~ age:sex + time + age:time,
                  data = data,
                  exposure = exposure) |>
  set_prior(age:sex ~ RW2()) |>
  set_prior(time ~ Lin_AR()) |>
  set_prior(age:time ~ RW_Seas(n = 12, s_seas = 0)) |>
  fit()
)

saveRDS(mod, file = .out)

