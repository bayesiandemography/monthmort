
suppressPackageStartupMessages({
  library(bage)
  library(command)
  library(dplyr, warn.conflict = FALSE)
  library(rvec, warn.conflict = FALSE)
  library(lubridate)
  library(ggplot2)
  library(poputils)
})

cmd_assign(.mod = "out/mod.rds",
           .out = "out/fig_paper_repdata_month.pdf")

mod <- readRDS(.mod)

set.seed(1)

data <- replicate_data(mod) |>
  mutate(year = year(time),
         month = month(time)) |>
  filter(year %in% 1999:2019) |>
  count(.replicate, year, month, wt = deaths, name = "deaths") |>
  mutate(deaths = deaths / 1000)

p <- ggplot(data, aes(x = month, y = deaths, group = year)) +
  facet_wrap(vars(.replicate)) +
  geom_line(alpha = 0.4) +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  xlab("Month") +
  ylab("Deaths (000)") +
  theme(legend.position = "top",
        legend.title = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 6))


graphics.off()
pdf(file = .out,
    width = 6,
    height = 6.5)
plot(p)
dev.off()        
