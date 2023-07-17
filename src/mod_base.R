
library(bage)
library(dplyr)
library(command)
library(lubridate)
library(rvec)

cmd_assign(deaths = "out/deaths.rds",
           exposure = "out/exposure.rds",
           start_date = "2010-01-01",
           .out = "out/mod_base.rds")

data <- inner_join(rename(deaths, deaths = count),
                   rename(exposure, exposure = count),
                   by = c("age", "sex", "time")) %>%
    mutate(time = paste0(time, "-15"),
           time = ymd(time)) %>%
    filter(time > ymd(start_date))

system.time(
mod <- mod_pois(deaths ~ age * sex + age * time,
                data = data,
                exposure = exposure) %>%
    set_prior(age ~ RW2()) %>%
    set_prior(time ~ RW2()) %>%
    fit()
)

mod



comp <- components(mod)

comp %>%
    filter(component == "par",
           term == "age") %>%
    mutate(draws_ci(value)) %>%
    ggplot(aes(x = age_mid(level),
               ymin = value.lower,
               y = value.mid,
               ymax = value.upper)) +
    geom_ribbon(fill = "darkorange") +
    geom_line(col = "darkred",
              linewidth = 0.1)
    
    

    
    
aug <- augment(mod)

aug %>%
    filter(sex == "Female") %>%
    filter(age %in% c("0", "20-24", "40-44", "60-64", "80-84")) %>%
    mutate(draws_ci(.fitted)) %>%
    ggplot(aes(x = time,
               ymin = .fitted.lower,
               y = .fitted.mid,
               ymax = .fitted.upper)) +
    facet_wrap(vars(age)) +
    geom_ribbon(fill = "darkorange") +
    geom_line(col = "darkred",
              linewidth = 0.1) +
    geom_point(aes(y = .observed),
               col = "darkblue",
               size = 0.2) +
    scale_y_log10()

    
