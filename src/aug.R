
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(mod = "out/mod_precovid.rds",
           .out = "out/aug_precovid.rds")

set.seed(0)

aug <- mod |>
  augment() |>
  select(-.expected)

saveRDS(aug, file = .out)

