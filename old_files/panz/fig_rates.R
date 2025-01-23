
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(ggplot2)

cmd_assign(mod = "../out/mod.rds",
           .out = "fig_rates.pdf")

levels_age <- c("45-49", "90-94")

aug <- augment(mod)

data <- aug %>%
    filter(age %in% levels_age,
           sex == "Female") %>%
    mutate(draws_ci(.fitted)) %>%
    mutate(age = paste("Age", age))


p <- ggplot(data,
            aes(x = time,
                ymin = .fitted.lower,
                y = .fitted.mid,
                ymax = .fitted.upper)) +
    facet_wrap(vars(age), ncol = 1, scale = "free_y") +
    geom_ribbon(fill = "lightblue") +
    geom_line(col = "darkblue",
              linewidth = 0.25) +
    geom_point(aes(y = .observed),
               col = "darkred",
               size = 0.25) +
    scale_x_date(breaks = "1 year") +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))

graphics.off()
pdf(file = .out,
    width = 7,
    height = 5)
plot(p)
dev.off()
    

