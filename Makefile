
START_DATE = 2010-02-01
END_DATE = 2020-02-01

.PHONY: all
all: out/fig_direct.pdf \
     out/fig_mod.pdf \
     out/fig_repdata.pdf \
     out/fig_time.pdf \
     out/fig_season.pdf \
     out/fig_rates.pdf \
     out/fig_lifeexp.pdf

out/deaths.rds: src/deaths.R \
  data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2023M5.csv.gz
	Rscript $^ $@

out/popn.rds: src/popn.R \
  data/DPE403901_20230817_110132_82.csv.gz
	Rscript $^ $@

out/exposure.rds: src/exposure.R \
  out/deaths.rds \
  out/popn.rds
	Rscript $^ $@

out/fig_direct.pdf: src/fig_direct.R \
  out/deaths.rds \
  out/exposure.rds
	Rscript $^ $@ --start_date=$(START_DATE)

out/mod.rds: src/mod.R \
  out/deaths.rds \
  out/exposure.rds
	Rscript $^ $@ --start_date=$(START_DATE) --end_date=$(END_DATE)

out/fig_mod.pdf: src/fig_mod.R \
  out/mod.rds
	Rscript $^ $@

out/fig_repdata.pdf: src/fig_repdata.R \
  out/mod.rds
	Rscript $^ $@

out/fig_time.pdf: src/fig_time.R \
  out/mod.rds
	Rscript $^ $@

out/fig_season.pdf: src/fig_season.R \
  out/mod.rds
	Rscript $^ $@

out/fig_rates.pdf: src/fig_rates.R \
  out/mod.rds
	Rscript $^ $@

out/fig_lifeexp.pdf: src/fig_lifeexp.R \
  out/mod.rds
	Rscript $^ $@



## Clean

.PHONY: clean
clean:
	rm -rf out
	mkdir out
