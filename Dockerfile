
## On Silicon Mac can't use rocker/tidyverse: https://github.com/rocker-org/rocker-versioned2/issues/144
FROM rocker/rstudio 

COPY data home/rstudio/data
COPY src home/rstudio/src
COPY Makefile home/rstudio/Makefile

RUN mkdir home/rstudio/out

RUN R -q -e 'install.packages("zoo")'
RUN R -q -e 'install.packages("readr")'
RUN R -q -e 'install.packages("dplyr")'
RUN R -q -e 'install.packages("tidyr")'
RUN R -q -e 'install.packages("ggplot2")'
RUN R -q -e 'install.packages("patchwork")'
RUN R -q -e 'install.packages("lubridate")'
RUN R -q -e 'install.packages("rvec")'
RUN R -q -e 'install.packages("poputils")'
RUN R -q -e 'install.packages("bage")'
RUN R -q -e 'install.packages("remotes")'
RUN R -q -e 'remotes::install_github("bayesiandemography/command")'

WORKDIR /home/rstudio

RUN make