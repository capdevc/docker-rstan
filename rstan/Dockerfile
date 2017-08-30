# forked from jrnold/docker-stan
FROM rocker/verse:latest
MAINTAINER Cristian Capdevila dockerstan@defvar.org

# Install some dependencies
RUN apt-get update && \
	  apt-get install -y --no-install-recommends apt-utils ed libnlopt-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

# Make ~/.R
RUN mkdir -p $HOME/.R
COPY files/Makevars $HOME/.R/Makevars
COPY files/Rprofile $HOME/.Rprofile

# There's a problem with BH 1.64 and stan at the moment
# https://github.com/stan-dev/rstan/issues/441
RUN R -e "library(devtools); \
           install_version('BH', version = '1.62.0-1');"

# Install packages
RUN install2.r --error --deps TRUE \
    rstan \
	  loo \
	  bayesplot \
    rstanarm \
    rstantools \
    shinystan \
    ggmcmc \
    mice

# We want the experimental version of rethinking
RUN R -e "library(devtools); \
          devtools::install_github('rmcelreath/rethinking',ref = 'Experimental'); \
          devtools::install_github('hadley/multidplyr');"

# Install data.table. We do this seperately not to pull in the wierd "suggests"
# Currently GenomicRanges doesn't seem to exist for # 3.4.1
RUN install2.r --error data.table

# Clear some space
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds
