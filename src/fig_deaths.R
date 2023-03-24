
library(ggplot2)
library(dplyr)
library(command)
library(lubridate)

cmd_assign(deaths = "out/deaths.rds",
           .out = "out/fig_deaths.pdf")

data <- deaths %>%
    mutate(time = paste0(time, "-15"),
           time = ymd(time))

p <- ggplot(data, aes(x = time, y = count, color = sex)) +
    facet_wrap(vars(age)) +
    geom_line(linewidth = 0.25) +
    scale_y_log10() +
    xlab("") +
    ylab("") +
    theme(legend.position = "top",
          legend.title = element_blank()) +
    ggtitle("Deaths (log scale)")

graphics.off()
pdf(file = .out,
    width = 10,
    height = 12)
plot(p)
dev.off()
