
library(readr)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(poputils)
library(command)

cmd_assign(p_popn = "data/DPE403901_20230814_011926_27.csv.gz",
           .out = "out/popn.rds")

age_labels <- age_labels(type = "single", max = 95)
col_names <- c("time",
               paste("Male", age_labels, sep = "."),
               paste("Female", age_labels, sep = "."))
col_types <- paste(rep(c("c", "i"), times = c(1, 2 * length(age_labels))),
                   collapse = "")

popn <- read_csv(p_popn,
                 skip = 4,
                 n_max = 129,
                 col_names = col_names,
                 col_types = col_types) %>%
    pivot_longer(cols = -time,
                 names_to = c("sex", "age"),
                 names_sep = "\\.") %>%
    mutate(age = reformat_age(age),
           age = combine_age(age, to = "lt")) %>%
    count(age, sex, time, wt = value, name = "count")

saveRDS(popn, file = .out)

