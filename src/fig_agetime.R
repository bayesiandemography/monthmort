
library(bage)
library(dplyr, warn.conflicts = FALSE)
library(command)
library(rvec, warn.conflicts = FALSE)
library(poputils)
library(tidyr, warn.conflicts = FALSE)
library(ggplot2)
library(lubridate, warn.conflicts = FALSE)

cmd_assign(mod = "out/mod_precovid.rds",
           col_fill = "lightblue",
           col_line = "black",
           .out = "out/fig_agetime.pdf")

comp <- components(mod)

data <- comp %>%
  filter(term == "age:time",
         component != "hyper") %>%
  separate_wider_delim(level, delim = ".", names = c("age", "time")) %>%
  mutate(age = reformat_age(age)) %>%
    filter(age %in% c("10-14", "40-44", "70-74", "95+")) %>%
    mutate(time = as.Date(time)) %>%
  mutate(draws_ci(.fitted)) %>%
  mutate(component = factor(component,
                            levels = c("effect",
                                       "trend", "seasonal"),
                            labels = c("Age-time Interaction",
                                       "Trend Component",
                                       "Seasonal Component")),
         age = paste("Age", age))

p <- ggplot(data,
            aes(x = time,
                y = .fitted.mid)) +
  facet_grid(vars(age), vars(component)) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill,
              alpha = 0.5) +
  geom_line(col = col_line,
            linewidth = 0.25) +
  scale_x_date(breaks = "1 year",
               date_labels = "%Y") +
  ylim(-1, 1) +
  ylab("") +
  xlab("") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

graphics.off()
pdf(file = .out,
    width = 6,
    height = 6)
plot(p)
dev.off()        


