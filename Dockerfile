# forked from jrnold/docker-stan
FROM rocker/verse:latest
MAINTAINER Cristian Capdevila dockerstan@defvar.org

# RUN export ADD=shiny && bash /etc/cont-init.d/add

# Install some dependencies
RUN apt-get update && \
	  apt-get install -y --no-install-recommends apt-utils ed libnlopt-dev ccache awscli libglu1-mesa-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

# Make ~/.R
RUN mkdir -p /root/.R
COPY files/Makevars /root/.R/Makevars

RUN mkdir -p /home/rstudio/.R
COPY files/Makevars /home/rstudio/.R/Makevars

# There's a problem with BH 1.64 and stan at the moment
# https://github.com/stan-dev/rstan/issues/441
RUN R -e "library(devtools); \
           install_version('BH', version = '1.62.0-1');" && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install packages
RUN install2.r --error --deps TRUE \
    rstan \
	  loo \
	  bayesplot \
    rstanarm \
    rstantools \
    shinystan \
    ggmcmc \
    brms \
    boot \
    doMC \
    glmnet \
    mice && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install data.table. We do this seperately not to pull in the wierd "suggests"
# Currently GenomicRanges doesn't seem to exist for R 3.4.1
RUN install2.r --error data.table && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install some additional packages
RUN install2.r --error --deps TRUE \
    purrr \
    DMwR \
    caret \
    pROC  \
    PRROC && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# We want the experimental version of rethinking
RUN R -e "library(devtools); \
          devtools::install_github('rmcelreath/rethinking',ref = 'Experimental'); \
          devtools::install_github('hadley/multidplyr');" && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

COPY files/Rprofile /root/.Rprofile
COPY files/Rprofile /home/rstudio/.Rprofile

# An attempt to fix R sessions crashing when running Stan. Possible disk space issue.
# Mount /tmp to the host /tmp dir
VOLUME ["/tmp"]
