
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(.vals = "out/vals_heldback.rds",
           col_line = "darkorange",
           col_point = "#1F4E79",
           .out = "out/fig_heldback.pdf")

vals <- readRDS(.vals)

p <- ggplot(vals, aes(x = forecast_period)) +
  facet_wrap(vars(age), scale = "free_y", nrow = 2) +
  geom_errorbar(aes(ymin = deaths_forecast.lower,
                    ymax = deaths_forecast.upper),
                color = col_line) +
  geom_point(aes(y = deaths_forecast.mid),
             color = col_line) +
  geom_point(aes(y = deaths_true),
             col = col_point,
             size = 1.2) +
  ylim(0, NA) +
  xlab("Forecast period") +
  ylab("Deaths (000)") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  

pdf(file = .out,
    width = 6,
    height = 6)
plot(p)
dev.off()
