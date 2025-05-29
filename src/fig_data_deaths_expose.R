
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(patchwork)
  library(command)
})

cmd_assign(.data_deaths_expose = "out/data_deaths_expose.rds",
           .out = "out/fig_data_deaths_expose.rds")

data_deaths_expose <- readRDS(.data_deaths_expose)

p_deaths <- data_deaths_expose |>
  filter(series == "Deaths") |>
  ggplot(aes(x = age_mid, y = value, color = factor(time))) +
  facet_grid(vars(sex), vars(series)) +
  geom_line() +
  scale_color_manual(values = c("#63a3cc", "#08306b")) +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "none")

p_expose <- data_deaths_expose |>
  filter(series == "Exposure") |>
  ggplot(aes(x = age_mid, y = value, color = factor(time))) +
  facet_grid(vars(sex), vars(series)) +
  geom_line() +
  scale_color_manual(values = c("#63a3cc", "#08306b")) +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "top",
        legend.title = element_blank())

p_lograte <- data_deaths_expose |>
  filter(series == "Log Rate") |>
  ggplot(aes(x = age_mid, y = value, color = factor(time))) +
  facet_grid(vars(sex), vars(series)) +
  geom_line() +
  scale_color_manual(values = c("#63a3cc", "#08306b")) +
  xlab("Age") +
  ylab("") +
  theme(legend.position = "none")


p <- p_deaths + p_expose + p_lograte

pdf(file = .out,
    width = 6,
    height = 4)
plot(p)
dev.off()

