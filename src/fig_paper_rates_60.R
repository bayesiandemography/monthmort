
suppressPackageStartupMessages({
  library(dplyr)
  library(lubridate)
  library(ggplot2)
  library(command)
})


cmd_assign(data = "out/data.rds",
           end_date = "2019-12-31",
           .out = "out/fig_paper_rates_60.pdf")

end_date <- ymd(end_date)

data_plot <- data |>
  filter(time <= end_date) |>
  filter(age == "60-64") |>
  mutate(time = year(time)) |>
  group_by(sex, age, time) |>
  summarise(deaths = sum(deaths),
            exposure = sum(exposure),
            .groups = "drop") |>
  mutate(rate = deaths / exposure) |>
  mutate(sex = factor(sex, levels = c("Male", "Female")))
           

p <- ggplot(data_plot, aes(x = time, y = rate, color = sex)) +
  geom_vline(xintercept = 2013, color = "grey60") +
  geom_line() +
  scale_color_manual(values = c("darkorange", "darkgreen")) +
  ylim(0, NA) +
  ylab("") +
  xlab("") +
  scale_x_continuous(minor_breaks = 1) +
  theme(legend.title = element_blank())

graphics.off()
pdf(file = .out,
    width = 3.5,
    height = 3)
plot(p)
dev.off()        


