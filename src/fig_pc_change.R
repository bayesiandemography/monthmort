
suppressPackageStartupMessages({
  library(ggplot2)
  library(command)
})

cmd_assign(.pc_change = "out/pc_change.rds",
           .out = "out/fig_pc_change.pdf")

pc_change <- readRDS(.pc_change)

p <- ggplot(pc_change, aes(x = 0, xend = pc_change, y = age)) +
  facet_grid(vars(sex), vars(series)) +
  geom_segment(linewidth = 0.3,
               arrow = arrow(length = unit(0.15,"cm"))) +
  xlab("Percent") +
  ylab("") +
  theme(text = element_text(size = 10))

pdf(file = .out,
    width = 5,
    height = 3)
plot(p)
dev.off()        

