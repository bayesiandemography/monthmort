
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(lubridate)
  library(ggplot2)
  library(patchwork)
  library(grid)
  library(command)
})

cmd_assign(excess = "out/excess.rds",
           col_fill = "lightblue",
           col_line = "darkblue",
           .out = "out/fig_paper_calc_excess.pdf")

excess_ag <- excess |>
  mutate(age = age_lower(age),
         age = 10 * (age %/% 10),
         age = case_when(age < 50 ~ "0-49",
                         age >= 50 & age < 90 ~ paste(age, age + 9, sep = "-"),
                         age >= 90 ~ "90+"),
         age = paste("Age", age)) |>
  group_by(age, time) |>
  summarise(expected = sum(expected),
            observed = sum(observed),
            excess = sum(excess),
            .groups = "drop") |>
  mutate(draws_ci(expected)) |>
  mutate(draws_ci(excess))

p_observed <- ggplot(excess_ag, aes(x = time)) +
  facet_wrap(vars(age), nrow = 1) +
  geom_line(aes(y = observed),
            col = col_line) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  ylim(-250, 1500) +
  ylab("") +
  xlab("") +
  theme(text = element_text(size = 10),
        axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Observed")

minus <- wrap_elements(textGrob("-",
                               gp = gpar(fontsize = 18)))

p_expected <- ggplot(excess_ag, aes(x = time)) +
  facet_wrap(vars(age), nrow = 1) +
  geom_ribbon(aes(ymin = expected.lower,
                  ymax = expected.upper),
              fill = col_fill) +
  geom_line(aes(y = expected.mid),
            col = col_line) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  ylim(-250, 1500) +
  ylab("") +
  xlab("") +
  theme(text = element_text(size = 10),
        axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Forecasted")

equals <- wrap_elements(textGrob("=",
                               gp = gpar(fontsize = 18)))


p_excess <- ggplot(excess_ag, aes(x = time)) +
  facet_wrap(vars(age), nrow = 1) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            col = col_line) +
  geom_hline(yintercept = 0, linewidth = 0.25) +
  ylim(-250, 1500) +
  ylab("") +
  xlab("") +
  theme(text = element_text(size = 10),
        axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Excess")


p <- p_observed + minus + p_expected + equals + p_excess +
  plot_layout(ncol = 1, heights = c(1, 0.08, 1, 0.08, 1))

graphics.off()
pdf(file = .out,
    width = 7.5,
    height = 9)
plot(p)
dev.off()        


