
suppressPackageStartupMessages({
  library(command)
})

cmd_assign(.out = "out/example_ages.rds")

example_ages <- c("10-14", "35-39", "60-64", "80-84", "95+")

saveRDS(example_ages, file = .out)
