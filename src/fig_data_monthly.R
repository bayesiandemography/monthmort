
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
  geom_point(size = 0.2) +
  scale_x_date(breaks = seq.Date(from = as.Date("2000-01-01"),
                                 to = as.Date("2025-01-01"),
                                 by = "5 year"),
               date_minor_breaks = "1 year",
               date_labels = "%Y") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE),
                     limits = c(0, NA)) +
  xlab("") +
  ylab("")

pdf(file = .out,
    width = 6,
    height = 5)
plot(p)
dev.off()
