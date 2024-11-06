
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
  mod <- mod_pois(deaths ~ age * sex + age * time + sex * time,
                  data = data,
                  exposure = exposure) |>
    set_prior(age ~ RW2_Infant()) |>
    set_prior(age:sex ~ RW2(zero_sum = TRUE)) |>
    set_prior(time ~ Lin_AR()) |>
    set_prior(age:time ~ RW2_Seas(n_seas = 12, s_seas = 0, zero_sum = TRUE)) |>
    set_prior(sex:time ~ RW2(zero_sum = TRUE)) |>
    set_datamod_outcome_rr3() |>
    fit()
)

saveRDS(mod, file = .out)

