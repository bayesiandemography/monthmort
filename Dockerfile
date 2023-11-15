
FROM rocker/tidyverse

COPY data home/rstudio/data
COPY src home/rstudio/src
COPY Makefile home/rstudio/Makefile
COPY README.txt home/rstudio/README.txt


RUN mkdir home/rstudio/out

RUN R -q -e 'install.packages("coda")'
RUN R -q -e 'devtools::install_github("statisticsnz/dembase")'
RUN R -q -e 'devtools::install_github("statisticsnz/demest")'

WORKDIR /home/rstudio

