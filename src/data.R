
suppressPackageStartupMessages({
  library(dplyr)
  library(command)
})

cmd_assign(.deaths = "out/deaths.rds",
           .exposure = "out/exposure.rds",
           .out = "out/data.rds")

deaths <- readRDS(.deaths)
exposure <- readRDS(.exposure)

data <- inner_join(deaths, exposure, by = c("age", "sex", "time"))

saveRDS(data, file = .out)
