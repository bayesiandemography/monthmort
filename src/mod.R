
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(lubridate)
})

cmd_assign(data = "out/data.rds",
           start_date = "1998-01-01",
           end_date = "2020-02-01",
           .out = "out/mod_precovid.rds")

data <- data |>
  filter(time > ymd(start_date),
         time < ymd(end_date))

mod <- mod_pois(deaths ~ age:sex + age:time + sex:time + time,
                data = data,
                exposure = exposure) |>
  set_prior(age:sex ~ RW2_Infant()) |>
  set_prior(age:time ~ RW2_Seas(n_seas = 12, sd = 0, con = "by")) |>
  set_prior(sex:time ~ RW2(sd = 0, con = "by")) |>
  set_prior(time ~ Lin_AR()) |>
  set_datamod_outcome_rr3() |>
  fit()

print(mod)

saveRDS(mod, file = .out)

