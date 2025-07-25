
suppressPackageStartupMessages({
  library(dplyr)
  library(poputils)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           .out = "out/excess_age.rds")

excess <- readRDS(.excess)

excess_age <- excess |>
  mutate(age = age_lower(age),
         age = 10 * (age %/% 10),
         age = case_when(age < 50 ~ "0-49",
                         age >= 50 & age < 90 ~ paste(age, age + 9, sep = "-"),
                         age >= 90 ~ "90+"),
         age = paste("Age", age)) |>
  count(age, time, wt = excess, name = "excess")

saveRDS(excess_age, file = .out)


