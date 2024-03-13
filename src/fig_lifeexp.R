

library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
library(lubridate)

cmd_assign(mod = "out/mod.rds",
           .out = "out/fig_lifeexp.pdf")

aug <- augment(mod)

col_fill <- "#FF7F50"
col_line <- "#2F4F4F"

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
    xlab("") +
    theme(text = element_text(size = 18))

graphics.off()
pdf(file = .out,
    width = 8,
    height = 5.5)
plot(p)
dev.off()        


