START_DATE = 1998-01-01
END_DATE = 2020-01-31
END_DATE_ALL = 2025-02-28
N_MAX_POPN = 137

COL_FILL = \#A6CEE3
COL_LINE = \#1F4E79
COL_POINT = \#D73027
COL_FILL_1 = \#A6D854
COL_LINE_1 = \#228B22
COL_FILL_2 = \#CC79A7
COL_LINE_2 = \#7E1E9C

.PHONY: all
all: out/fig_data_deaths_expose.pdf \
     out/fig_data_monthly.pdf \
     out/fig_time.pdf \
     out/fig_agesextime.pdf \
     out/fig_season.pdf \
     out/fig_rates.pdf \
     out/fig_repdata_lifeexp.pdf \
     out/fig_repdata_month.pdf \
     out/fig_heldback.pdf \
     out/fig_excess.pdf \
     out/fig_excess_ag.pdf \
     out/fig_agesextime_supp.pdf \
     out/fig_season_supp.pdf \
     out/fig_rates_all_female.pdf \
     out/fig_rates_all_male.pdf \
     out/fig_excess_agesex_female.pdf \
     out/fig_excess_agesex_male.pdf \
     out/fig_repdata_lifeexp_supp.pdf \
     out/fig_repdata_month_supp.pdf


## Prepare data

out/deaths.rds: src/deaths.R \
  data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2025M2.csv.gz
	Rscript $^ $@

out/popn.rds: src/popn.R \
  data/DPE403901_20250516_063419_2.csv.gz
	Rscript $^ $@ --n_max_popn=$(N_MAX_POPN)

out/exposure.rds: src/exposure.R \
  out/popn.rds
	Rscript $^ $@

out/data.rds: src/data.R \
  out/deaths.rds \
  out/exposure.rds
	Rscript $^ $@

out/example_ages.rds: src/example_ages.R
	Rscript $^ $@


## Plots of raw data

out/data_deaths_expose.rds: src/data_deaths_expose.R \
  out/data.rds
	Rscript $^ $@ 

out/data_monthly.rds: src/data_monthly.R \
  out/data.rds \
  out/example_ages.rds
	Rscript $^ $@ --start_date=$(START_DATE) \
                      --end_date=$(END_DATE)


## Fit model and derive values

out/mod.rds: src/mod.R \
  out/data.rds
	Rscript $^ $@ --start_date=$(START_DATE) \
                      --end_date=$(END_DATE)

out/aug.rds: src/aug.R \
  out/mod.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE)

out/comp.rds: src/comp.R \
  out/mod.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE)

out/excess.rds: src/excess.R \
  out/aug.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --end_date_all=$(END_DATE_ALL)


## Model checks

out/repdata_lifeexp.rds: src/repdata_lifeexp.R \
  out/mod.rds
	Rscript $^ $@

out/repdata_month.rds: src/repdata_month.R \
  out/mod.rds
	Rscript $^ $@

out/heldback.rds: src/heldback.R \
  out/data.rds
	Rscript $^ $@ --start_date=$(START_DATE) \
                      --end_date_first=2008-01-31 \
                      --end_date_last=2015-01-31 \
                      --years_forecast=5


## Figures for main part of paper

out/fig_data_deaths_expose.pdf: src/fig_data_deaths_expose.R \
  out/data_deaths_expose.rds
	Rscript $^ $@

out/fig_data_monthly.pdf: src/fig_data_monthly.R \
  out/data_monthly.rds
	Rscript $^ $@

out/fig_time.pdf: src/fig_time.R \
  out/comp.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_agesextime.pdf: src/fig_agesextime.R \
  out/comp.rds \
  out/example_ages.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --use_example_ages=TRUE \
                      --col_fill_1=$(COL_FILL_1) \
                      --col_line_1=$(COL_LINE_1) \
                      --col_fill_2=$(COL_FILL_2) \
                      --col_line_2=$(COL_LINE_2)

out/fig_season.pdf: src/fig_season.R \
  out/comp.rds \
  out/example_ages.rds
	Rscript $^ $@ --use_example_ages=TRUE \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_rates.pdf: src/fig_rates.R \
  out/aug.rds \
  out/example_ages.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

out/fig_repdata_lifeexp.pdf: src/fig_repdata_lifeexp.R \
  out/repdata_lifeexp.rds
	Rscript $^ $@ --use_all=FALSE \
                      --col_line_1=$(COL_LINE_1) \
                      --col_line_2=$(COL_LINE_2)

out/fig_repdata_month.pdf: src/fig_repdata_month.R \
  out/repdata_month.rds
	Rscript $^ $@  --use_all=FALSE


out/fig_heldback.pdf: src/fig_heldback.R \
  out/heldback.rds
	Rscript $^ $@ --col_line=darkorange \
                      --col_point=blue

out/fig_excess.pdf: src/fig_excess.R \
  out/excess.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_excess_ag.pdf: src/fig_excess_ag.R \
  out/excess.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)


## Figures for supplementary part of paper

out/fig_season_supp.pdf: src/fig_season.R \
  out/comp.rds \
  out/example_ages.rds
	Rscript $^ $@ --use_example_ages=FALSE \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_agesextime_supp.pdf: src/fig_agesextime.R \
  out/comp.rds \
  out/example_ages.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --use_example_ages=FALSE \
                      --col_fill_1=$(COL_FILL_1) \
                      --col_line_1=$(COL_LINE_1) \
                      --col_fill_2=$(COL_FILL_2) \
                      --col_line_2=$(COL_LINE_2)

out/fig_rates_all_female.pdf: src/fig_rates_all.R \
  out/aug.rds
	Rscript $^ $@ --sex=Female \
                      --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

out/fig_rates_all_male.pdf: src/fig_rates_all.R \
  out/aug.rds
	Rscript $^ $@ --sex=Male \
                      --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

out/fig_excess_agesex_female.pdf: src/fig_excess_agesex.R \
  out/excess.rds
	Rscript $^ $@ --sex=Female \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_excess_agesex_male.pdf: src/fig_excess_agesex.R \
  out/excess.rds
	Rscript $^ $@ --sex=Male \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_repdata_lifeexp_supp.pdf: src/fig_repdata_lifeexp.R \
  out/repdata_lifeexp.rds
	Rscript $^ $@ --use_all=TRUE \
                      --col_line_1=$(COL_LINE_1) \
                      --col_line_2=$(COL_LINE_2)

out/fig_repdata_month_supp.pdf: src/fig_repdata_month.R \
  out/repdata_month.rds
	Rscript $^ $@ --use_all=TRUE


## Copy to directory for paper

.PHONY: copy
copy:
	cp out/fig*.pdf ../monthmort_paper/figures


## Clean

.PHONY: clean
clean:
	rm -rf out
	mkdir out
