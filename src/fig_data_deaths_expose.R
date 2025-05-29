
suppressPackageStartupMessages({
  library(ggplot2)
  library(poputils)
  library(command)
})

cmd_assign(.data_deaths_expose = "out/data_deaths_expose.rds",
           .out = "out/fig_data_deaths_expose.rds")

data_deaths_expose <- readRDS(.data_deaths_expose)

p <- ggplot(data_deaths_expose,
            aes(x = age_mid, y = value, color = factor(time))) +
  facet_grid(vars(series), vars(sex), scale = "free_y") +
  geom_line() +
  scale_color_manual(values = c("#63a3cc", "#08306b")) +
  xlab("Age") +
  ylab("") +
  theme(legend.title = element_blank())

pdf(file = .out,
    width = 5,
    height = 5)
plot(p)
dev.off()

