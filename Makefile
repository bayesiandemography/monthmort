
COL_LINE = "darkblue"
COL_FILL = "lightblue"
COL_POINT = "red"

.PHONY: all
all: out/fig_diag_precovid.pdf \
     out/fig_diag_forecast.pdf \
     out/fig_excess_pc.pdf \
     out/fig_diff_lifeexp.pdf \
     kathmandu/kathmandu.pdf \
     out/fig_time_effect.pdf


## Prepare data

out/deaths.rds: src/deaths.R \
  data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2024M6.csv.gz
	Rscript $^ $@

out/popn.rds: src/popn.R \
  data/DPE403901_20241119_124334_98.csv.gz
	Rscript $^ $@

out/exposure.rds: src/exposure.R \
  out/popn.rds
	Rscript $^ $@

out/data.rds: src/data.R \
  out/deaths.rds \
  out/exposure.rds
	Rscript $^ $@


## Fit models and derive values from them

out/mod_precovid.rds: src/mod.R \
  out/data.rds
	Rscript $^ $@ --start_date=1998-01-01 --end_date=2020-02-01

out/mod_all.rds: src/mod.R \
  out/data.rds
	Rscript $^ $@ --start_date=1998-01-01 --end_date=2024-06-01

out/aug_precovid.rds: src/aug.R \
  out/mod_precovid.rds
	Rscript $^ $@

out/aug_all.rds: src/aug.R \
  out/mod_all.rds
	Rscript $^ $@

out/forecast.rds: src/forecast.R \
  out/mod_precovid.rds \
  out/data.rds \
  out/aug_precovid.rds
	Rscript $^ $@

out/comp_all.rds: src/comp.R \
  out/mod_all.rds
	Rscript $^ $@


## Diagnostic plots

out/fig_diag_precovid.pdf: src/fig_diag.R \
  out/aug_precovid.rds
	Rscript $^ $@ --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
                      --col_point=$(COL_POINT)

out/fig_diag_all.pdf: src/fig_diag.R \
  out/aug_all.rds
	Rscript $^ $@ --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
                      --col_point=$(COL_POINT)

out/fig_diag_forecast.pdf: src/fig_diag_forecast.R \
  out/forecast.rds \
  out/aug_precovid.rds
	Rscript $^ $@ --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
                      --col_point=$(COL_POINT)


## Excess deaths

out/excess_deaths.rds: src/excess_deaths.R \
  out/forecast.rds \
  out/data.rds
	Rscript $^ $@


## Kathmandu poster

kathmandu/dag.pdf: kathmandu/dag.tex
	cd kathmandu; R -e 'tinytex::latexmk("dag.tex")' --quiet

kathmandu/fig_forecasted_rates.pdf: kathmandu/fig_forecasted_rates.R \
  out/aug_precovid.rds \
  out/forecast.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

kathmandu/fig_calc_excess.pdf: kathmandu/fig_calc_excess.R \
  out/data.rds \
  out/forecast.rds
	Rscript $^ $@ --end_date=2024-06-01 \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

kathmandu/fig_excess_age.pdf: kathmandu/fig_excess_age.R \
  out/data.rds \
  out/forecast.rds
	Rscript $^ $@ --end_date=2024-01-01 \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

kathmandu/fig_lifeexp.pdf: kathmandu/fig_lifeexp.R \
  out/aug_all.rds
	Rscript $^ $@


kathmandu/kathmandu.pdf: kathmandu/kathmandu.tex \
  kathmandu/dag.pdf \
  kathmandu/fig_forecasted_rates.pdf \
  kathmandu/fig_calc_excess.pdf \
  kathmandu/fig_excess_age.pdf \
  kathmandu/fig_lifeexp.pdf
	cd kathmandu; R -e 'tinytex::latexmk("kathmandu.tex")' --quiet




## Plots for paper

out/fig_excess_pc.pdf: src/fig_excess_pc.R \
  out/excess_deaths.rds
	Rscript $^ $@ --end_date=2024-06-01 \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)


out/fig_diff_lifeexp.pdf: src/fig_diff_lifeexp.R \
  out/excess_deaths.rds
	Rscript $^ $@ --end_date=2024-06-01 \
                      --col_line=$(COL_LINE)

out/fig_time_effect.pdf: src/fig_time_effect.R \
  out/comp_all.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) --col_line=$(COL_LINE)


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
