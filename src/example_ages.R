
suppressPackageStartupMessages({
  library(command)
})

cmd_assign(.out = "out/example_ages.rds")

example_ages <- c("10-14", "40-44", "70-74", "90-94")

saveRDS(example_ages, file = .out)
