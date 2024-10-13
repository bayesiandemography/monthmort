
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(data = "out/data.rds",
           start_date = "2000-02-01",
           end_date = "2020-02-01",
           .out = "out/mod.rds")

data <- data |>
  filter(time > ymd(start_date),
         time < ymd(end_date))

system.time(
  mod <- mod_pois(deaths ~ age:sex + time + age:time,
                  data = data,
                  exposure = exposure) |>
  set_prior(age:sex ~ RW2()) |>
  set_prior(time ~ Lin_AR()) |>
  set_prior(age:time ~ RW2_Seas(n_seas = 12, s_seas = 0)) |>
  set_datamod_outcome_rr3() |>
  fit()
)

saveRDS(mod, file = .out)

