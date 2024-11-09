
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(mod = "out/mod_excess.rds",
           .out = "out/aug_excess.rds")

aug <- mod |>
  augment() |>
  select(-.expected)

saveRDS(aug, file = .out)

