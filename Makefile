
START_DATE = 2000-02-01
END_DATE = 2020-02-01

COL_LINE = "darkblue"
COL_POINT = "red"

.PHONY: all
all: out/fig_diag_inputs.pdf \
     out/fig_diag_mod.pdf \
     out/fig_diag_forecast.pdf \
     out/fig_repdata.pdf \
     out/fig_time.pdf \
     out/fig_agetime.pdf \
     out/fig_rates.pdf \
     out/fig_lifeexp.pdf


## Prepare data

out/deaths.rds: src/deaths.R \
  data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2023M5.csv.gz
	Rscript $^ $@

out/popn.rds: src/popn.R \
  data/DPE403901_20230817_110132_82.csv.gz
	Rscript $^ $@

out/exposure.rds: src/exposure.R \
  out/popn.rds
	Rscript $^ $@

out/data.rds: src/data.R \
  out/deaths.rds \
  out/exposure.rds
	Rscript $^ $@


## Fit model and make forecasts

out/mod.rds: src/mod.R \
  out/data.rds
	Rscript $^ $@ --start_date=$(START_DATE) --end_date=$(END_DATE)

out/forecast_aug.rds: src/forecast_aug.R \
  out/mod.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE)

out/forecast_comp.rds: src/forecast_comp.R \
  out/mod.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE)


## Diagnostic plots

out/fig_diag_inputs.pdf: src/fig_diag_inputs.R \
  out/data.rds
	Rscript $^ $@ --start_date=$(START_DATE)

out/fig_diag_mod.pdf: src/fig_diag_mod.R \
  out/mod.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) --col_line=$(COL_LINE) --col_point=$(COL_POINT)

out/fig_diag_forecast.pdf: src/fig_diag_forecast.R \
  out/forecast_aug.rds \
  out/forecast_comp.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

## Plots for paper

out/fig_repdata.pdf: src/fig_repdata.R \
  out/mod.rds
	Rscript $^ $@

out/fig_time.pdf: src/fig_time.R \
  out/mod.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) --col_line=$(COL_LINE)

out/fig_agetime.pdf: src/fig_agetime.R \
  out/mod.rds 
	Rscript $^ $@ --col_fill=$(COL_FILL) --col_line=$(COL_LINE)

out/fig_rates.pdf: src/fig_rates.R \
  out/mod.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) --col_line=$(COL_LINE) --col_point=$(COL_POINT)

out/fig_lifeexp.pdf: src/fig_lifeexp.R \
  out/mod.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) --col_line=$(COL_LINE)









## Clean

.PHONY: clean
clean:
	rm -rf out
	mkdir out
