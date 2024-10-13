
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(deaths = "out/deaths.rds",
           exposure = "out/exposure.rds",
           .out = "out/data.rds")

data <- inner_join(deaths, exposure, by = c("age", "sex", "time"))

saveRDS(data, file = .out)
