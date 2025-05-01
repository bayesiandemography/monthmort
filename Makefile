START_DATE = 1998-01-01
END_DATE = 2020-01-31
END_DATE_ALL = 2024-11-30

COL_FILL = \#A6CEE3
COL_LINE = \#1F4E79
COL_POINT = \#D73027
COL_FILL_1 = \#A6D854
COL_LINE_1 = \#228B22
COL_FILL_2 = \#CC79A7
COL_LINE_2 = \#7E1E9C

.PHONY: all
all: out/fig_diag_mod.pdf \
     out/fig_diag_heldback.pdf \
     out/fig_paper_heldback.pdf \
     out/fig_paper_time.pdf \
     out/fig_paper_agesextime.pdf \
     out/fig_paper_season.pdf \
     out/fig_paper_rates.pdf \
     out/fig_paper_excess.pdf \
     out/fig_paper_excess_age.pdf \
     out/fig_paper_agesextime_supp.pdf \
     out/fig_paper_season_supp.pdf \
     out/fig_paper_excess_agesex_female.pdf \
     out/fig_paper_excess_agesex_male.pdf \
     out/fig_paper_repdata_lifeexp.pdf \
     out/fig_paper_repdata_month.pdf


## Prepare data

out/deaths.rds: src/deaths.R \
  data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2024M12.csv.gz
	Rscript $^ $@

out/popn.rds: src/popn.R \
  data/DPE403901_20250318_012204_94.csv.gz
	Rscript $^ $@

out/exposure.rds: src/exposure.R \
  out/popn.rds
	Rscript $^ $@

out/data.rds: src/data.R \
  out/deaths.rds \
  out/exposure.rds
	Rscript $^ $@

out/example_ages.rds: src/example_ages.R
	Rscript $^ $@


## Fit model and derive values

out/mod.rds: src/mod.R \
  out/data.rds
	Rscript $^ $@ --start_date=$(START_DATE) --end_date=$(END_DATE)

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

out/heldback.rds: src/heldback.R \
  out/data.rds
	Rscript $^ $@ --start_date=$(START_DATE) \
                      --end_date_first=2007-01-31 \
                      --end_date_last=2015-01-31 \
                      --years_forecast=5


## Figures for diagnostics (not included in paper)

out/fig_diag_mod.pdf: src/fig_diag_mod.R \
  out/aug.rds \
  out/comp.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
                      --col_point=$(COL_POINT)

out/fig_diag_heldback.pdf: src/fig_diag_heldback.R \
  out/heldback.rds
	Rscript $^ $@ --col_line=grey70 \
                      --col_point=blue


## Figures for main part of paper

out/fig_paper_time.pdf: src/fig_paper_time.R \
  out/comp.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_agesextime.pdf: src/fig_paper_agesextime.R \
  out/comp.rds \
  out/example_ages.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --use_example_ages=TRUE \
                      --col_fill_1=$(COL_FILL_1) \
                      --col_line_1=$(COL_LINE_1) \
                      --col_fill_2=$(COL_FILL_2) \
                      --col_line_2=$(COL_LINE_2)

out/fig_paper_season.pdf: src/fig_paper_season.R \
  out/comp.rds
	Rscript $^ $@ --use_example_ages=TRUE \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_rates.pdf: src/fig_paper_rates.R \
  out/aug.rds \
  out/example_ages.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

out/fig_paper_heldback.pdf: src/fig_paper_heldback.R \
  out/heldback.rds
	Rscript $^ $@ --col_line=darkorange \
                      --col_point=blue

out/fig_paper_excess.pdf: src/fig_paper_excess.R \
  out/excess.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_excess_age.pdf: src/fig_paper_excess_age.R \
  out/excess.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)


## Figures for supplementary part of paper

out/fig_paper_season_supp.pdf: src/fig_paper_season.R \
  out/comp.rds
	Rscript $^ $@ --use_example_ages=FALSE \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_agesextime_supp.pdf: src/fig_paper_agesextime.R \
  out/comp.rds \
  out/example_ages.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --use_example_ages=FALSE \
                      --col_fill_1=$(COL_FILL_1) \
                      --col_line_1=$(COL_LINE_1) \
                      --col_fill_2=$(COL_FILL_2) \
                      --col_line_2=$(COL_LINE_2)

out/fig_paper_excess_agesex_female.pdf: src/fig_paper_excess_agesex.R \
  out/excess.rds
	Rscript $^ $@ --sex=Female \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_excess_agesex_male.pdf: src/fig_paper_excess_agesex.R \
  out/excess.rds
	Rscript $^ $@ --sex=Male \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_repdata_lifeexp.pdf: src/fig_paper_repdata_lifeexp.R \
  out/mod.rds
	Rscript $^ $@ --col_line_1=$(COL_LINE_1) \
                      --col_line_2=$(COL_LINE_2)

out/fig_paper_repdata_month.pdf: src/fig_paper_repdata_month.R \
  out/mod.rds
	Rscript $^ $@


## Copy to directory for paper

.PHONY: copy
copy:
	cp out/fig_paper*.pdf ../monthmort_paper/figures


## Clean

.PHONY: clean
clean:
	rm -rf out
	mkdir out
