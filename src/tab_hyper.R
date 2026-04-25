
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(xtable)
  library(command)
})

cmd_assign(.mod = "out/mod.rds",
           .out = "out/tab_hyper.rds")

mod <- readRDS(.mod)

comp <- mod |>
  components()

out <- comp |>
  filter(component %in% c("hyper", "disp")) |>
  mutate(Median = draws_median(.fitted),
         "2.5\\%" = draws_quantile(.fitted, prob = 0.025)[[1L]],
         "97.5\\%" = draws_quantile(.fitted, prob = 0.975)[[1L]]) |>
  mutate(Median = formatC(Median, digits = 3, format = "fg"),
         "2.5\\%" = formatC(`2.5\\%`, digits = 3, format = "fg"),
         "97.5\\%" = formatC(`97.5\\%`, digits = 3, format = "fg")) |>
  select(Term = term , Parameter = level, Median, `2.5\\%`, `97.5\\%`) |>
  mutate(Term = c("Time", "Time", "Time", "Time",
                  "Age-sex",
                  "Age-time",
                  "Sex-time",
                  "Dispersion")) |>
  mutate(Parameter = c("Coef $\\phi_1$",
                       "Coef $\\phi_2$",
                       "Std dev $\\tau_{\\mathcal{T}}$",
                       "Slope $\\eta^{\\mathcal{T}}$",
                       "Std dev $\\tau_{\\mathcal{AS}}$",
                       "Std dev $\\tau_{\\mathcal{AT}}$",
                       "Std dev $\\tau_{\\mathcal{ST}}$",
                       "Dispersion $\\xi$")) |>
  xtable(caption = "Estimates for selected hyper-parameters",
         label = "tab:hyper") |>
  print(file = .out,
        sanitize.colnames.function = identity,
        sanitize.text.function = identity,
        include.rownames = FALSE,
        caption.placement = "top")

