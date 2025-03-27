
suppressPackageStartupMessages({
  library(bage)
  library(dplyr)
  library(command)
  library(lubridate)
})

cmd_assign(data = "out/data.rds",
           start_date = "1998-01-01",
           end_date_first = "2007-01-31",
           end_date_last = "2015-01-31",
           years_forecast = 5,
           .out = "out/heldback.rds")

start_date <- ymd(start_date)
end_date_first <- ymd(end_date_first)
end_date_last <- ymd(end_date_last)
end_dates <- seq(from = end_date_first, to = end_date_last, by = "1 year")
heldback <- lapply(end_dates, function(x) NULL)
names(heldback) <- year(end_dates)
for (i in seq_along(end_dates)) {
  end_date <- end_dates[[i]]
  cat("Fitting model to data for period",
      format(start_date, "%Y-%m-%d"),
      "to",
      format(end_date, "%Y-%m-%d"),
      "\n")
  ## obtained data for fitting model
  data_fit <- data |>
    filter(time >= ymd(start_date),
           time <= ymd(end_date))
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
    fit()
  print(mod)
  ## do forecast
  cat("Doing forecast for period",
      format(head(labels_forecast, 1L), "%Y-%m-%d"),
      "to",
      format(tail(labels_forecast, 1L), "%Y-%m-%d"),
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

