
library(dplyr)
library(tidyr)
library(ggplot2)

lik_errorfree <- function(gamma, y, w)
  dpois(y, w * gamma)

lik_rr3 <- function(gamma, y, w)
  ifelse(y == 0L,
         dpois(0, w * gamma) + (2/3) * dpois(1, w * gamma) + (1/3) * dpois(2, w * gamma),
         (1/3) * dpois(y - 2, w * gamma) + (2/3) * dpois(y - 1, w * gamma)
         + dpois(y, w * gamma)
         + (2/3) * dpois(y + 1, w * gamma) + (1/3) * dpois(y + 2, w * gamma))


data <- expand_grid(y = c(0, 3),
                    w = c(100, 200, 300, 400),
                    gamma = seq(0.0001, 0.1, 0.0001)) |>
  mutate(errorfree = lik_errorfree(gamma = gamma, y = y, w = w),
         rr3 = lik_rr3(gamma = gamma, y = y, w = w)) |>
  pivot_longer(c(errorfree, rr3), names_to = "likelihood") |>
  mutate(y = paste("y = ", y),
         w = paste("w = ", w))

ggplot(data, aes(x = gamma, y = value, linetype = likelihood)) +
  facet_grid(vars(y), vars(w)) +
  geom_line()

         

  
                    






    
