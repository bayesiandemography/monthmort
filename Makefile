
START_DATE = 2010-01-01

.PHONY: all
all: out/fig_direct.pdf \
     out/fig_mod.pdf

out/deaths.rds: src/deaths.R \
  data/Deaths_registered_in_NZ_by_month_of_death_1998M1-2023M2.csv.gz
	Rscript $^ $@

out/popn.rds: src/popn.R \
  data/DPE403901_20230814_011926_27.csv.gz
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
	Rscript $^ $@ --start_date=$(START_DATE)

out/fig_mod.pdf: src/fig_mod.R \
  out/mod.rds
	Rscript $^ $@


## Clean

.PHONY: clean
clean:
	rm -rf out
	mkdir out
