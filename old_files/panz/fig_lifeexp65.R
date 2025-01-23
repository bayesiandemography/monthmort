
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec)
library(poputils)
library(ggplot2)

cmd_assign(mod = "../out/mod.rds",
           .out = "fig_lifeexp65.pdf")

aug <- augment(mod)

data <- aug %>%
    filter(age_lower(age) >= 65) %>%
    group_by(sex, time) %>%
    summarise(lifeexp = lifeexp(.fitted, age = age),
              .groups = "drop") %>%
    mutate(draws_ci(lifeexp))

p <- ggplot(data,
            aes(x = time,
                ymin = lifeexp.lower,
                y = lifeexp.mid,
                ymax = lifeexp.upper)) +
    geom_ribbon(aes(fill = sex)) +
    scale_fill_manual(values = c(Female = "darkseagreen", Male = "lightsalmon")) +
    geom_line(aes(col = sex),
              linewidth = 0.25) +
    scale_color_manual(values = c(Female = "darkgreen", Male = "darkred")) +
    scale_x_date(breaks = "1 year") +
    xlab("") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "top",
          legend.title = element_blank())

graphics.off()
pdf(file = .out,
    width = 7,
    height = 5)
plot(p)
dev.off()
    

