
library(bage)
library(command)
library(dplyr, warn.conflict = FALSE)
library(rvec, warn.conflict = FALSE)
library(tidyr)
library(ggplot2)
library(poputils)

cmd_assign(mod = "out/mod.rds",
           .out = "out/fig_repdata.pdf")


## Percentage change in age-specific mortality rates

repdata_age <- replicate_data(mod, condition_on = "meanpar") %>%
  mutate(year = format(time, format = "%Y")) %>%
  group_by(.replicate, age, year) %>%
  summarise(deaths = sum(deaths), exposure = sum(exposure),
            .groups = "drop") %>%
  filter(year %in% range(year)) %>%
  mutate(year = ifelse(year == min(year), "first", "last")) %>%
  mutate(direct = deaths / exposure) %>%
  select(-deaths, -exposure) %>%
  pivot_wider(names_from = year, values_from = direct) %>%
  mutate(pc_change = 100 * (last / first - 1))

p_age <- ggplot(repdata_age, aes(x = age_mid(age), y = pc_change)) +
    facet_wrap(vars(.replicate)) +
    geom_point() +
    geom_line() +
    ggtitle("Percentage change in direct estimates of age-specific mortality rates",
            subtitle = "Last year vs first year")



## Direct estimates of life expectancy

repdata_life <- replicate_data(mod, condition_on = "meanpar") %>%
    mutate(mx = deaths / exposure) %>%
    lifeexp(mx = mx,
            sex = sex,
            by = c(.replicate, time))

p_life <- ggplot(repdata_life, aes(x = time, y = ex, col = sex)) +
    facet_wrap(vars(.replicate)) +
    geom_line() +
    ggtitle("Direct estimates of life expectancy, by month and sex")


graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
plot(p_age)
plot(p_life)
dev.off()        
