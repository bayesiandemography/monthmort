
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(command)
})

cmd_assign(.repdata_lifeexp = "out/repdata_lifeexp.rds",
           use_all = FALSE,
           col_line_1 = "#228B22",
           col_line_2 = "#7E1E9C",
           .out = "out/fig_repdata_lifeexp.pdf")

repdata_lifeexp <- readRDS(.repdata_lifeexp)

if (!use_all) {
  repdata_lifeexp <- repdata_lifeexp |>
    filter(.replicate %in% unique(.replicate)[1:8])
}

p <- ggplot(repdata_lifeexp, aes(x = time, y = ex, col = sex)) +
  facet_wrap(vars(.replicate), ncol = 4) +
  geom_line(linewidth = 0.2) +
  scale_color_manual(values = c(col_line_1, col_line_2)) +
  scale_x_date(breaks = seq(from = as.Date("2000-01-01"),
                            to = as.Date("2020-01-01"),
                            by = "10 years"),
               date_minor_breaks = "1 year",
               date_labels = "%Y") +
  xlab("Time") +
  ylab("Years") +
  theme(legend.position = "top",
        legend.title = element_blank())

pdf(file = .out,
    width = 6,
    height = if (use_all) 7.5 else 4)
plot(p)
dev.off()        
