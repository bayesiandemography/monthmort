
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(poputils)
  library(ggplot2)
})

cmd_assign(.aug = "out/aug_all.rds",
           end_date = as.Date("2020-01-31"),
           .out = "out/fig_paper_lifeexp.pdf")

aug <- readRDS(.aug)

data <- aug |>
  lifeexp(mx = .fitted,
          by = c(sex, time)) |>
  mutate(draws_ci(ex))

p <- ggplot(data, aes(x = time)) +
  geom_vline(xintercept = end_date,
             linetype = "dashed",
             linewidth = 0.25) +
  geom_ribbon(aes(ymin = ex.lower,
                  ymax = ex.upper,
                  fill = sex),
              alpha = 0.25) +
  geom_line(aes(y = ex.mid,
                color = sex),
            linewidth = 0.2) +
  scale_x_date(date_minor_breaks = "1 year") +
  scale_y_continuous(minor_breaks = 2) +
  scale_fill_manual(values = c("darkgreen", "darkorange")) +
  scale_color_manual(values = c("darkgreen", "darkorange")) +
  ylab("") +
  xlab("") +
  theme(legend.position = "top",
        legend.title = element_blank())

graphics.off()
pdf(file = .out,
    width = 7,
    height = 5)
plot(p)
dev.off()        


