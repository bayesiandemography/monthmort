
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
library(lubridate)

cmd_assign(mod = "out/mod.rds",
           col_fill = "steelblue1",
           col_line = "black",
           .out = "out/fig_lifeexp.pdf")

aug <- augment(mod)

data <- aug %>%
    lifeexp(mx = .fitted,
            by = c(sex, time)) %>%
    mutate(draws_ci(ex))

p <- ggplot(data,
            aes(x = time,
                y = ex.mid)) +
    facet_wrap(vars(sex)) +
    geom_ribbon(aes(ymin = ex.lower,
                    ymax = ex.upper),
                fill = col_fill,
                alpha = 0.5) +
    geom_line(col = col_line,
              linewidth = 0.25) +
    ylab("") +
    xlab("")

graphics.off()
pdf(file = .out,
    width = 8,
    height = 5.5)
plot(p)
dev.off()        


