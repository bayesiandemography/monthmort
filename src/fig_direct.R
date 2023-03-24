
library(ggplot2)
library(dplyr)
library(command)
library(lubridate)

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


p <- ggplot(data, aes(x = time, y = rate, color = sex)) +
    facet_wrap(vars(age)) +
    geom_line(linewidth = 0.25) +
    scale_y_log10() +
    xlab("") +
    ylab("") +
    theme(legend.position = "top",
          legend.title = element_blank()) +
    ggtitle("Direct estimates of mortality rates (log scale)")

graphics.off()
pdf(file = .out,
    width = 10,
    height = 12)
plot(p)
dev.off()
