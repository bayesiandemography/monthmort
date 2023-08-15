
library(ggplot2)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(deaths = "out/deaths.rds",
           exposure = "out/exposure.rds",
           start_date = "2010-01-01",
           .out = "out/fig_exposure.pdf")

data <- inner_join(rename(deaths, deaths = count),
                   rename(exposure, exposure = count),
                   by = c("age", "sex", "time")) %>%
    mutate(rate = deaths / exposure) %>%
    mutate(time = paste0(time, "-15"),
           time = ymd(time)) %>%
    filter(time > ymd(start_date))

p_deaths <- ggplot(data, aes(x = time, y = deaths, color = sex)) +
    facet_wrap(vars(age)) +
    geom_line(linewidth = 0.25) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    xlab("") +
    ylab("") +
    theme(legend.position = "top",
          legend.title = element_blank()) +
    ggtitle("Deaths (log scale)")

p_exposure <- ggplot(data, aes(x = time, y = exposure, color = sex)) +
    facet_wrap(vars(age)) +
    geom_line(linewidth = 0.25) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    xlab("") +
    ylab("") +
    theme(legend.position = "top",
          legend.title = element_blank()) +
    ggtitle("Exposure (log scale)")

p_direct <- ggplot(data, aes(x = time, y = rate, color = sex)) +
    facet_wrap(vars(age)) +
    geom_line(linewidth = 0.25) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    xlab("") +
    ylab("") +
    theme(legend.position = "top",
          legend.title = element_blank()) +
    ggtitle("Direct estimates of mortality rates (log scale)")


graphics.off()
pdf(file = .out,
    width = 10,
    height = 12,
    onefile = TRUE)
plot(p_deaths)
plot(p_exposure)
plot(p_direct)
dev.off()        
