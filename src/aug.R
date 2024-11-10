
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(mod = "out/mod_precovid.rds",
           .out = "out/aug_precovid.rds")

aug <- mod |>
  augment() |>
  select(-.expected)

saveRDS(aug, file = .out)

