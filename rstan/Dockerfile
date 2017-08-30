# forked from jrnold/docker-stan
FROM rocker/verse:latest
MAINTAINER Jeffrey Arnold jeffrey.arnold@gmail.com

RUN apt-get update \
	&& apt-get install -y --no-install-recommends apt-utils ed libnlopt-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

# Install rstan
RUN install2.r --error --deps TRUE \
    rstan \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Global site-wide config -- neeeded for building packages
RUN mkdir -p $HOME/.R/ \
    && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs \n" >> $HOME/.R/Makevars

# Config for rstudio user
RUN mkdir -p $HOME/.R/ \
    && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs -Wno-ignored-attributes -Wno-deprecated-declarations\n" >> $HOME/.R/Makevars \
    && echo "rstan::rstan_options(auto_write = TRUE)\n" >> /home/rstudio/.Rprofile \
    && echo "options(mc.cores = parallel::detectCores())\n" >> /home/rstudio/.Rprofile

# Install rstan
RUN install2.r --error --deps TRUE devtools
RUN R - e "library(devtools); \
           install_version('BH', version = '1.62.0-1');"
RUN install2.r --error --deps TRUE \
    data.table \
    devtools \
    rstan \
	  loo \
	  bayesplot \
    rstanarm \
    rstantools \
    shinystan \
    ggmcmc \
    mice
RUN R -e "library(devtools); \
          devtools::install_github('rmcelreath/rethinking',ref = 'Experimental'); \
          devtools::install_github('hadley/multidplyr');"
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds
