
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(poputils)
  library(ggplot2)
  library(tidyr)
  library(command)
})

cmd_assign(excess = "out/excess.rds",
           col_fill = "lightblue",
           col_line = "darkblue",
           .out = "out/fig_paper_diff_lifeexp.pdf")

excess <- excess |>
  group_by(age, time) |>
  summarise(expected = sum(expected),
            exposure = sum(exposure),
            observed = sum(observed),
            .groups = "drop")
  
data_expected <- excess |>
  mutate(mx = expected / exposure) |>
  lifeexp(mx = mx,
          by = time) |>
  mutate(variant = "expected")

data_observed <- excess |>
  mutate(mx = observed / exposure) |>
  lifeexp(mx = mx,
          by = time) |>
  mutate(variant = "observed")

data <- bind_rows(data_expected, data_observed) |>
  pivot_wider(names_from = variant, values_from = ex) |>
  mutate(excess = observed - expected) |>
  mutate(draws_ci(excess))
  
p <- ggplot(data, aes(x = time)) +
  geom_ribbon(aes(ymin = excess.lower,
                  ymax = excess.upper),
              fill = col_fill) +
  geom_line(aes(y = excess.mid),
            col = col_line) +
  geom_hline(yintercept = 0,
             linewidth = 0.25) +
  ylab("") + 
  xlab("")

graphics.off()
pdf(file = .out,
    w = 6,
    h = 3)
plot(p)
dev.off()
