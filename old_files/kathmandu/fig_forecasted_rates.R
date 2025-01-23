
suppressPackageStartupMessages({
  library(dplyr)
  library(rvec)
  library(ggplot2)
  library(command)
})


cmd_assign(aug = "out/aug_precovid.rds",
           forecast = "out/forecast.rds",
           col_fill = "lightblue",
           col_line = "darkblue",
           col_point = "red",
           .out = "out/fig_forecasted_rates.pdf")

ages_show <- c("40-44", "75-79", "90-94")

data <- bind_rows(aug, forecast) |>
  filter(sex == "Female") |>
  filter(age %in% ages_show) |>
  mutate(age = paste("Females, age", age)) |>
  mutate(draws_ci(.fitted))

p <- ggplot(data, aes(x = time)) +
  facet_wrap(vars(age),
             scale = "free_y",
             ncol = 1) +
  geom_ribbon(aes(ymin = .fitted.lower,
                  ymax = .fitted.upper),
              fill = col_fill) +
  geom_line(aes(y = .fitted.mid),
            col = col_line,
            linewidth = 0.4) +
  geom_point(aes(y = .observed),
             col = col_point,
             size = 0.2) +
  geom_vline(xintercept = as.Date("2020-02-15"),
             linetype = "dashed",
             linewidth = 0.25) +
  scale_x_date(date_minor_breaks = "1 year") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  ylab("") +
  xlab("")

graphics.off()
pdf(file = .out,
    width = 4,
    height = 4.5)
plot(p)
dev.off()        


