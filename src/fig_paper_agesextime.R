
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(tidyr)
  library(poputils)
  library(lubridate)
  library(ggplot2)
  library(command)
})

cmd_assign(.comp = "out/comp.rds",
           .example_ages = "out/example_ages.rds",
           end_date = as.Date("2020-01-31"),
           use_example_ages = TRUE,
           col_fill_1 = "#A6D854",
           col_line_1 = "#228B22",
           col_fill_2 = "#CC79A7",
           col_line_2 = "#7E1E9C",
           .out = "out/fig_paper_agesextime.pdf")

comp <- readRDS(.comp)
example_ages <- readRDS(.example_ages)

intercept <-  comp |>
  filter(term == "(Intercept)") |>
  pull(.fitted)

age_sex <- comp |>
  filter(term == "age:sex",
         component == "effect") |>
  separate_wider_delim(level, delim = ".", names = c("age", "sex")) |>
  select(age, sex, age_sex = .fitted)

sex_time <- comp |>
  filter(term == "sex:time",
         component == "effect") |>
  separate_wider_delim(level, delim = ".", names = c("sex", "time")) |>
  select(sex, time, sex_time = .fitted)

age_time_trend <- comp |>
  filter(term == "age:time",
         component == "trend") |>
  separate_wider_delim(level, delim = ".", names = c("age", "time")) |>
  select(age, time, age_time_trend = .fitted)

time_trend <- comp |>
  filter(term == "time",
         component == "trend") |>
  select(time = level, time_trend = .fitted)
  
age_sex_time <- age_sex |>
  inner_join(sex_time, by = "sex", relationship = "many-to-many") |>
  inner_join(age_time_trend, by = c("age", "time")) |>
  inner_join(time_trend, by = "time")

if (use_example_ages) {
  age_sex_time <- age_sex_time |>
    filter(age %in% example_ages)
} 

age_sex_time <- age_sex_time |>
  mutate(age = factor(age, levels = unique(age))) |>
  mutate(.fitted = intercept + age_sex + sex_time + age_time_trend + time_trend) |>
  select(age, sex, time, .fitted) |>
  mutate(time = as.Date(time)) |>
  mutate(draws_ci(.fitted)) |>
  mutate(age = paste("Age", age),
         age = factor(age, levels = unique(age)))

p <- ggplot(age_sex_time, aes(x = time)) +
  facet_wrap(vars(age)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper,
                  fill = sex),
              alpha = 0.4) +
  geom_line(aes(y = .fitted.mid,
                col = sex),
            linewidth = 0.2) +
  geom_vline(xintercept = end_date,
             linetype = "dashed",
             linewidth = 0.25) +
  scale_fill_manual(values = c(col_fill_1, col_fill_2)) +
  scale_color_manual(values = c(col_line_1, col_line_2)) +
  xlab("") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank())

if (use_example_ages)
  p <- p + facet_wrap(vars(age), nrow = 1)

graphics.off()
pdf(file = .out,
    width = 6,
    height = if (use_example_ages) 3 else 7.5)
plot(p)
dev.off()
