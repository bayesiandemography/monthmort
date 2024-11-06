
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec, warn.conflicts = FALSE)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
 
cmd_assign(forecast_aug = "out/forecast_aug.rds",
           forecast_comp = "out/forecast_comp.rds",
           end_date = "2020-02-01",
           col_fill = "lightblue",
           col_line = "darkblue",
           col_point = "red",
           .out = "out/fig_diag_forecast.pdf")


end_date <- as.Date(end_date)


## Hyper-parameters -----------------------------------------------------------





## Mortality rates ------------------------------------------------------------

p_age_rates <- lapply(levels_age, plot_age_rates)


## Life expectancy ------------------------------------------------------------


## Print in one document ------------------------------------------------------

graphics.off()
pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)
plot(p_time)
plot(p_time_trend)
plot(p_time_error)
plot(p_agetime)
plot(p_agetime_trend)
plot(p_agetime_season)
for (p in p_age_rates)
    plot(p)
plot(p_lifeexp)
dev.off()        
