
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(.heldback = "out/heldback.rds",
           col_line = "darkorange",
           col_point = "blue",
           .out = "out/fig_diag_heldback.pdf")

heldback <- readRDS(.heldback)

pdf(file = .out,
    width = 10,
    height = 10,
    onefile = TRUE)

for (end_year in unique(heldback$end_year)) {
  for (sex in unique(heldback$sex)) {

    data <- heldback |>
      mutate(draws_ci(deaths_forecast)) |>
      filter(end_year == !!end_year,
             sex == !!sex)

    p <- ggplot(data, aes(x = time)) +
      facet_wrap(vars(age), scale = "free_y", ncol = 3) +
      geom_pointrange(aes(ymin = deaths_forecast.lower,
                          y = deaths_forecast.mid,
                          ymax = deaths_forecast.upper),
                      col = col_line,
                      linewidth = 0.2,
                      fatten = 0.2) +
      geom_point(aes(y = deaths_true),
                 col = col_point,
                 size = 0.5) +
      ylim(0, NA) +
      xlab("") +
      ylab("") +
      ggtitle("Forecasted deaths (grey) vs actual deaths (blue)",
              subtitle = sprintf("%s, %s to %s",
                                 sex,
                                 format(min(data$time), "%B %Y"),
                                 format(max(data$time), "%B %Y")))

    plot(p)

  }
}

