
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(ggplot2)
  library(patchwork)
  library(grid)
  library(command)
})

cmd_assign(data = "out/data.rds",
           forecast = "out/forecast.rds",
           end_date = "2024-06-01",
           col_fill = "lightblue",
           col_line = "darkblue",
           col_point = "red",
           .out = "out/fig_calc_excess.pdf")

end_date <- as.Date(end_date)

expected <- forecast |>
  filter(time <= end_date) |>
  count(time, wt = .deaths, name = "expected")

observed <- data |>
  filter(time %in% expected$time) |>
  count(time, wt = deaths, name = "observed")

excess <- inner_join(expected, observed, by = "time") |>
  mutate(excess = observed - expected) |>
  mutate(draws_ci(excess))

expected <- expected |>
  mutate(draws_ci(expected))

p_observed <- ggplot(observed, aes(x = time)) +
  geom_line(aes(y = observed),
            col = col_line) +
  ylim(-1000, 4000) +
  ylab("Deaths per month") +
  xlab("") +
  theme(axis.title.y = element_text(size = 9)) +
  ggtitle("Observed")

minus <- wrap_elements(textGrob("-",
                               gp = gpar(fontsize = 36)))


p_expected <- ggplot(expected, aes(x = time)) +
  geom_ribbon(aes(ymin = expected.lower,
                  ymax = expected.upper),
              fill = col_fill) +
  geom_line(aes(y = expected.mid),
            col = col_line) +
  ylim(-1000, 4000) +
  ylab("Deaths per month") +
  xlab("") +
  theme(axis.title.y = element_text(size = 9)) +
  ggtitle("Forecasted")

equals <- wrap_elements(textGrob("=",
                               gp = gpar(fontsize = 36)))


p_excess <- ggplot(excess, aes(x = time)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            col = col_line) +
  geom_hline(yintercept = 0) +
  ylim(-1000, 4000) +
  ylab("Deaths per month") +
  xlab("") +
  theme(axis.title.y = element_text(size = 9)) +
  ggtitle("Excess")


p <- p_observed + minus + p_expected + equals + p_excess +
  plot_layout(ncol = 1, heights = c(1, 0.4, 1, 0.4, 1))

graphics.off()
pdf(file = .out,
    width = 4,
    height = 10)
plot(p)
dev.off()        


