
suppressPackageStartupMessages({
  library(bage)
  library(command)
  library(dplyr, warn.conflict = FALSE)
  library(rvec, warn.conflict = FALSE)
  library(tidyr)
  library(ggplot2)
  library(poputils)
})

cmd_assign(.mod = "out/mod.rds",
           col_line_1 = "#228B22",
           col_line_2 = "#7E1E9C",
           .out = "out/fig_paper_repdata_lifeexp.pdf")

mod <- readRDS(.mod)

set.seed(0)

data <- replicate_data(mod) |>
  mutate(mx = deaths / exposure) |>
  lifeexp(mx = mx,
          sex = sex,
          by = c(.replicate, time))

p <- ggplot(data, aes(x = time, y = ex, col = sex)) +
  facet_wrap(vars(.replicate), ncol = 4) +
  geom_line(linewidth = 0.2) +
  scale_color_manual(values = c(col_line_1, col_line_2)) +
  scale_x_date(breaks = seq(from = as.Date("2000-01-01"),
                            to = as.Date("2020-01-01"),
                            by = "5 years"),
               date_minor_breaks = "1 year",
               date_labels = "%Y") +
  xlab("Time") +
  ylab("Years") +
  theme(legend.position = "top",
        legend.title = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))


graphics.off()
pdf(file = .out,
    width = 6,
    height = 7.5)
plot(p)
dev.off()        
