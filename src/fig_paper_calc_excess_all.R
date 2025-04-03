
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(patchwork)
  library(grid)
  library(command)
})

cmd_assign(.excess = "out/excess.rds",
           col_fill = "#A6CEE3",
           col_line = "#1F4E79",
           .out = "out/fig_paper_calc_excess_all.pdf")

excess <- readRDS(.excess)

excess_ag <- excess |>
  group_by(time) |>
  summarise(expected = sum(expected),
            observed = sum(observed),
            excess = sum(excess)) |>
  mutate(draws_ci(expected)) |>
  mutate(draws_ci(excess))

p_observed <- ggplot(excess_ag, aes(x = time)) +
  geom_line(aes(y = observed),
            col = col_line) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ylim(-750, 4250) +
  ylab("") +
  xlab("") +
  theme(text = element_text(size = 10)) +
  ggtitle("Observed")

minus <- wrap_elements(textGrob("-",
                               gp = gpar(fontsize = 18)))

p_expected <- ggplot(excess_ag, aes(x = time)) +
  geom_ribbon(aes(ymin = expected.lower,
                  ymax = expected.upper),
              fill = col_fill) +
  geom_line(aes(y = expected.mid),
            col = col_line) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ylim(-750, 4250) +
  ylab("") +
  xlab("") +
  theme(text = element_text(size = 10)) +
  ggtitle("Forecasted")

equals <- wrap_elements(textGrob("=",
                               gp = gpar(fontsize = 18)))


p_excess <- ggplot(excess_ag, aes(x = time)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            col = col_line) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ylim(-750, 4250) +
  ylab("") +
  xlab("") +
  theme(text = element_text(size = 10)) +
  ggtitle("Excess")


p <- p_observed + minus + p_expected + equals + p_excess +
  plot_layout(ncol = 1, heights = c(1, 0.08, 1, 0.08, 1))

graphics.off()
pdf(file = .out,
    width = 2.8,
    height = 7)
plot(p)
dev.off()        


