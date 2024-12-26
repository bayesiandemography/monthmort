
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
})

cmd_assign(mod = "out/mod_all.rds",
           .out = "out/comp_all.rds")

comp <- mod |>
  components()
  
saveRDS(comp, file = .out)
