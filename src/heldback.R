
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(lubridate)
  library(command)
})

cmd_assign(.data = "out/data.rds",
           start_date = as.Date("1998-01-01"),
           end_date_first = as.Date("2007-01-31"),
           end_date_last = as.Date("2015-01-31"),
           years_forecast = 5L,
           .out = "out/heldback.rds")

data <- readRDS(.data)

options(width = 100) ## for printing of model output

end_dates <- seq(from = end_date_first, to = end_date_last, by = "1 year")
heldback <- lapply(end_dates, function(x) NULL)
names(heldback) <- year(end_dates)
for (i in seq_along(end_dates)) {
  end_date <- end_dates[[i]]
  cat("\n-------------------------------------------------------------------------------\n",
      "Fitting model to data for period",
      format(start_date, "%Y-%m"),
      "to",
      format(end_date, "%Y-%m"),
      "\n")
  ## obtained data for fitting model
  data_fit <- data |>
    filter(time >= start_date,
           time <= end_date)
  ## obtain data for forecasting
  labels_forecast <- seq(from = end_date %m+% days(15),
                         to = rollback(end_date %m+% years(years_forecast)) + days(15),
                         by = "month")
  newdata <- data |>
    filter(time %in% labels_forecast)
  ## fit model
  mod <- mod_pois(deaths ~ age:sex + age:time + sex:time + time,
                  data = data_fit,
                  exposure = exposure) |>
    set_prior(age:sex ~ RW2_Infant()) |>
    set_prior(age:time ~ RW2_Seas(n_seas = 12, sd = 0, con = "by")) |>
    set_prior(sex:time ~ RW2(sd = 0, con = "by")) |>
    set_prior(time ~ Lin_AR()) |>
    set_datamod_outcome_rr3() |>
    set_n_draw(n_draw = 2000) |>
    fit()
  print(mod)
  ## do forecast
  cat("Doing forecast for period",
      format(head(labels_forecast, 1L), "%Y-%m"),
      "to",
      format(tail(labels_forecast, 1L), "%Y-%m"),
      "\n")
  forecast <- mod |>
    forecast(newdata = newdata)
  ## get forecasted and actual deaths (both rr3)
  val <- forecast |>
    select(age, sex, time, deaths_forecast = deaths) |>
    inner_join(newdata, by = c("age", "sex", "time")) |>
    rename(deaths_true = deaths)
  heldback[[i]] <- val
}

heldback <- bind_rows(heldback, .id = "end_year")

saveRDS(heldback, file = .out)

