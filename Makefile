
COL_LINE = "darkblue"
COL_FILL = "lightblue"
COL_POINT = "red"

.PHONY: all
all: out/fig_diag_excess.pdf \
     out/fig_diag_analysis.pdf \
     out/forecast.rds


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


## Fit models and derive values from them

out/mod_excess.rds: src/mod.R \
  out/data.rds
	Rscript $^ $@ --start_date=1998-01-01 --end_date=2020-02-01

out/mod_analysis.rds: src/mod.R \
  out/data.rds
	Rscript $^ $@ --start_date=1998-01-01 --end_date=2023-06-01

out/aug_excess.rds: src/aug.R \
  out/mod_excess.rds
	Rscript $^ $@

out/aug_analysis.rds: src/aug.R \
  out/mod_analysis.rds
	Rscript $^ $@

out/forecast.rds: src/forecast.R \
  out/mod_excess.rds \
  out/data.rds \
  out/aug_excess.rds
	Rscript $^ $@


## Diagnostic plots for models

out/fig_diag_excess.pdf: src/fig_diag.R \
  out/aug_excess.rds
	Rscript $^ $@ --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
                      --col_point=$(COL_POINT)

out/fig_diag_analysis.pdf: src/fig_diag.R \
  out/aug_analysis.rds
	Rscript $^ $@ --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
                      --col_point=$(COL_POINT)



out/aug.rds: src/aug.R \
  out/mod.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE)

out/comp.rds: src/comp.R \
  out/mod.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE)


## Diagnostic plots

out/fig_diag.pdf: src/fig_diag.R \
  out/aug.rds \
  out/comp.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
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
