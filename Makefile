

.PHONY: all
all: out/fig_deaths.pdf \
     out/fig_exposure.pdf \
     out/fig_direct.pdf \
     out/fig_direct_post2019.pdf

out/deaths.rds: src/deaths.R \
  data/Monthly-death-registrations-by-ethnicity-age-sex-Jan2010-Dec2022.xlsx
	Rscript $^ $@

out/popn.rds: src/popn.R \
  data/DPE403901_20230324_084811_25.csv
	Rscript $^ $@

out/exposure.rds: src/exposure.R \
  out/deaths.rds \
  out/popn.rds
	Rscript $^ $@

out/fig_deaths.pdf: src/fig_deaths.R \
  out/deaths.rds
	Rscript $^ $@

out/fig_exposure.pdf: src/fig_exposure.R \
  out/exposure.rds
	Rscript $^ $@

out/fig_direct.pdf: src/fig_direct.R \
  out/deaths.rds \
  out/exposure.rds
	Rscript $^ $@ --start_date=2010-01-01

out/fig_direct_post2019.pdf: src/fig_direct.R \
  out/deaths.rds \
  out/exposure.rds
	Rscript $^ $@ --start_date=2019-01-01




## Clean

.PHONY: clean
clean:
	rm -rf out
	mkdir out
