
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(command)
})

cmd_assign(aug = "out/aug_all.rds",
           .out = "out/fig_lifeexp.pdf")

data <- aug |>
  lifeexp(mx = .fitted,
          by = c(sex, time)) |>
  rename(modelled = ex) |>
  mutate(draws_ci(modelled))

p <- ggplot(data, aes(x = time)) +
  geom_vline(xintercept = as.Date("2020-02-15"),
             linetype = "dashed",
             linewidth = 0.25) +
  geom_ribbon(aes(ymin = modelled.lower,
                  ymax = modelled.upper,
                  fill = sex),
              alpha = 0.25) +
  geom_line(aes(y = modelled.mid,
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
    width = 4,
    height = 4.5)
plot(p)
dev.off()        


