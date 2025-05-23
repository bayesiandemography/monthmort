
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(poputils)
  library(command)
})

cmd_assign(.mod = "out/mod.rds",
           .out = "out/repdata_lifeexp.rds")

mod <- readRDS(.mod)

set.seed(0)

repdata_lifeexp <- mod |>
  replicate_data() |>
  mutate(mx = deaths / exposure) |>
  lifeexp(mx = mx,
          sex = sex,
          by = c(.replicate, time))          

saveRDS(repdata_lifeexp, file = .out)
