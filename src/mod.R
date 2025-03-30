
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(.data = "out/data.rds",
           start_date = as.Date("1998-01-01"),
           end_date = as.Date("2020-01-31"),
           .out = "out/mod.rds")

data <- readRDS(.data)

data <- data |>
  filter(time >= start_date,
         time <= end_date)

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

