
suppressPackageStartupMessages({
  library(ggplot2)
  library(command)
})

cmd_assign(.data_monthly = "out/data_monthly.rds",
           .out = "out/fig_data_monthly.pdf")

data_monthly <- readRDS(.data_monthly)

p <- ggplot(data_monthly,
            aes(x = time, y = rate)) +
  facet_grid(vars(age), vars(sex), scale = "free_y") +
  ylim(0, NA) +         
  geom_point(size = 0.2)

pdf(file = .out,
    width = 5,
    height = 4.5)
plot(p)
dev.off()
