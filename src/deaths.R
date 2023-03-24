
library(readxl)
library(dplyr, warn.conflicts = FALSE)
library(poputils)
library(command)

cmd_assign(p_deaths =
               "data/Monthly-death-registrations-by-ethnicity-age-sex-Jan2010-Dec2022.xlsx",
           .out = "out/deaths.rds")

deaths <- read_xlsx(p_deaths, sheet = "Data") %>%
    filter(ethnicity == "Total") %>%
    select(-ethnicity) %>%
    mutate(time = sprintf("%d-%02.0f", year_reg, month_reg)) %>%
    select(-year_reg, -month_reg) %>%
    mutate(age = clean_age(age_group)) %>%
    select(age, sex, time, count)

saveRDS(deaths, file = .out)

