START_DATE = "1998-01-01"
END_DATE = "2020-01-31"
END_DATE_ALL = "2024-05-31"

COL_LINE = "darkblue"
COL_FILL = "lightblue"
COL_POINT = "red"

.PHONY: all
all: out/fig_diag_mod.pdf \
     out/fig_diag_mod_all.pdf \
     out/fig_diag_heldback.pdf \
     out/fig_paper_heldback.pdf \
     out/fig_paper_rates_60.pdf \
     out/fig_paper_time.pdf \
     out/fig_paper_rates.pdf \
     out/fig_paper_calc_excess.pdf \
     out/fig_paper_calc_excess_panel.pdf \
     out/fig_paper_cumulative_excess.pdf \
     out/fig_paper_diff_lifeexp.pdf \
     out/fig_paper_lifeexp.pdf \
     out/fig_paper_cyclical_all.pdf


## Prepare data

out/deaths.rds: src/deaths.R \
  data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2024M6.csv.gz
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
	Rscript $^ $@ --end_date=$(END_DATE)

out/heldback.rds: src/heldback.R \
  out/data.rds
	Rscript $^ $@ --start_date=$(START_DATE) \
                      --end_date_first=2007-01-31 \
                      --end_date_last=2016-01-31 \
                      --years_forecast=4

out/mod_all.rds: src/mod.R \
  out/data.rds
	Rscript $^ $@ --start_date=$(START_DATE) \
                      --end_date=$(END_DATE_ALL)

out/aug_all.rds: src/aug.R \
  out/mod_all.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE_ALL)

out/comp_all.rds: src/comp.R \
  out/mod_all.rds \
  out/data.rds
	Rscript $^ $@ --end_date=$(END_DATE_ALL)


## Figures for diagnostics (not included in paper)

out/fig_diag_mod.pdf: src/fig_diag_mod.R \
  out/aug.rds \
  out/comp.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
                      --col_point=$(COL_POINT)

out/fig_diag_mod_all.pdf: src/fig_diag_mod.R \
  out/aug_all.rds \
  out/comp_all.rds
	Rscript $^ $@ --end_date=$(END_DATE_ALL) \
                      --col_line=$(COL_LINE) \
                      --col_fill=$(COL_FILL) \
                      --col_point=$(COL_POINT)

out/fig_diag_heldback.pdf: src/fig_diag_heldback.R \
  out/heldback.rds
	Rscript $^ $@ --col_line=grey70 \
                      --col_point=blue


## Figures for main part of paper

out/fig_paper_heldback.pdf: src/fig_paper_heldback.R \
  out/heldback.rds
	Rscript $^ $@ --col_line=darkorange \
                      --col_point=blue

out/fig_paper_rates_60.pdf: src/fig_paper_rates_60.R \
  out/data.rds
	Rscript $^ $@ --end_date=2019-12-31

out/fig_paper_time.pdf: src/fig_paper_time.R \
  out/comp.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_rates.pdf: src/fig_paper_rates.R \
  out/aug.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE) \
                      --col_point=$(COL_POINT)

out/fig_paper_calc_excess.pdf: src/fig_paper_calc_excess.R \
  out/excess.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_calc_excess_panel.pdf: src/fig_paper_calc_excess_panel.R \
  out/excess.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_cumulative_excess.pdf: src/fig_paper_cumulative_excess.R \
  out/excess.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_diff_lifeexp.pdf: src/fig_paper_diff_lifeexp.R \
  out/excess.rds
	Rscript $^ $@ --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_cyclical_all.pdf: src/fig_paper_cyclical_all.R \
  out/comp_all.rds
	Rscript $^ $@ --end_date=$(END_DATE) \
                      --col_fill=$(COL_FILL) \
                      --col_line=$(COL_LINE)

out/fig_paper_lifeexp.pdf: src/fig_paper_lifeexp.R \
  out/aug_all.rds
	Rscript $^ $@ --end_date=$(END_DATE)


## Figures for supplementary material for paper



.PHONY: copy
copy:
	cp out/fig_paper*.pdf ../monthmort_paper/figures


## Clean

.PHONY: clean
clean:
	rm -rf out
	mkdir out
