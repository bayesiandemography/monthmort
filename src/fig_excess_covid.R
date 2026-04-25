
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(rvec)
  library(ggplot2)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           .covid_deaths = "out/covid_deaths.rds",
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_excess_covid.pdf")

excess <- readRDS(.excess)
covid_deaths <- readRDS(.covid_deaths)

data <- excess |>
  count(time, wt = excess, name = "excess") |>
  inner_join(covid_deaths, by = "time") |>
  mutate(draws_ci(excess))

p <- ggplot(data, aes(x = time)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            col = col_line) +
  geom_line(aes(y = deaths),
            col = "#E07A1F",
            linewidth = 1) +
  geom_hline(yintercept = 0,
             linewidth = 0.25) +
  ylab("Deaths") +
  xlab("")

pdf(file = .out,
    width = 4.5,
    height = 3)
plot(p)
dev.off()        


