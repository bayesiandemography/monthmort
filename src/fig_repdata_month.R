
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(command)
})

cmd_assign(.repdata_month = "out/repdata_month.rds",
           use_all = FALSE,
           .out = "out/fig_repdata_month.pdf")

repdata_month <- readRDS(.repdata_month)

if (!use_all) {
  repdata_month <- repdata_month |>
    filter(.replicate %in% unique(.replicate)[1:8])
}

p <- ggplot(repdata_month, aes(x = month, y = deaths, group = year)) +
  facet_wrap(vars(.replicate), ncol = 4) +
  geom_line(alpha = 0.4, linewidth = 0.2) +
  scale_x_continuous(breaks = c(1, 4, 7, 10),
                     minor_breaks = 1:12,
                     labels = c("Jan", "Apr", "Jul", "Oct")) +
  xlab("Month") +
  ylab("Deaths (000)") +
  theme(legend.position = "top",
        legend.title = element_blank(),
        axis.text.y = element_text(size = 8))

pdf(file = .out,
    width = 6,
    height = if (use_all) 7.5 else 4)
plot(p)
dev.off()        
