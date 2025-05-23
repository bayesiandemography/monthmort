
suppressPackageStartupMessages({
  library(ggplot2)
  library(command)
})

cmd_assign(.popn_change = "out/popn_change.rds",
           end_date = as.Date("2020-01-31"),
           .out = "out/fig_paper_popn_change.pdf")

popn_change <- readRDS(.popn_change)

p <- ggplot(popn_change, aes(x = 0, xend = popn_change, y = age)) +
  facet_wrap(vars(sex)) +
  geom_segment(linewidth = 0.3,
               arrow = arrow(length = unit(0.15,"cm"))) +
  xlab("Percent") +
  ylab("") +
  theme(text = element_text(size = 10))


pdf(file = .out,
    width = 4.5,
    height = 3)
plot(p)
dev.off()        

