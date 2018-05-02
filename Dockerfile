# forked from jrnold/docker-stan
FROM rocker/verse:3.4.4
MAINTAINER Cristian Capdevila dockerstan@defvar.org

# RUN export ADD=shiny && bash /etc/cont-init.d/add

# Install some dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        automake \
        cmake \
        libtool \
        pkg-config \
        sudo \
        bzip2 \
        ca-certificates \
        curl \
        gfortran \
        git \
        locales \
        unzip \
        wget \
        zip \
        ssh \
        bzip2 \
        ca-certificates \
        curl \
        fuse \
        mime-support \
        libcurl4-gnutls-dev \
        libfuse-dev \
        libssl-dev \
        libgl1-mesa-glx \
        libxml2-dev \
        apt-utils \
        ed \
        libnlopt-dev \
        ccache \
        awscli \
        libglu1-mesa-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

# Clone, build and install s3fs
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs-fuse && \
    cd /tmp/s3fs-fuse && \
    ./autogen.sh && \
    ./configure && \
    make && \
    sudo make install && \
    rm -rf /tmp/s3*

# Make ~/.R
RUN mkdir -p /root/.R
COPY files/Makevars /root/.R/Makevars

RUN mkdir -p /home/rstudio/.R
COPY files/Makevars /home/rstudio/.R/Makevars

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
    mice \
    data.table \
    purrr \
    DMwR \
    caret \
    pROC  \
    PRROC \
    && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

COPY files/mount-s3fs.sh /etc/cont-init.d/ZZ-mount-s3fs
COPY files/Rprofile /root/.Rprofile
COPY files/Rprofile /home/rstudio/.Rprofile

RUN mkdir /home/rstudio/notebooks
RUN chown rstudio /home/rstudio/notebooks

# An attempt to fix R sessions crashing when running Stan. Possible disk space issue.
# Mount /tmp to the host /tmp dir
VOLUME ["/tmp"]
