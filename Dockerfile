FROM rocker/verse:latest
MAINTAINER Cristian Capdevila dockerstan@defvar.org

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
        groff \
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
        libglu1-mesa-dev \
        python3 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

# Default to python 3.6
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.5 2 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1

# Clone, build and install s3fs
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs-fuse && \
    cd /tmp/s3fs-fuse && \
    ./autogen.sh && \
    ./configure && \
    make && \
    sudo make install && \
    rm -rf /tmp/s3*

# Install pip
RUN curl -SsL -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py 'pip==9' && \
    rm -f get-pip.py

RUN pip3 --no-cache-dir install s3cmd awscli boto3

# Make ~/.R
RUN mkdir -p /root/.R
COPY files/Makevars /root/.R/Makevars

RUN mkdir -p /home/rstudio/.R
COPY files/Makevars /home/rstudio/.R/Makevars

# Install packages
RUN install2.r --error --deps TRUE \
    pryr \
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
    fasttime \
    anytime \
    purrr \
    DMwR \
    caret \
    pROC  \
    PRROC \
    bsts \
    CausalImpact \
    && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN install2.r --error --deps TRUE \
    -r 'http://cloudyr.github.io/drat' \
    aws.s3 \
    && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

COPY files/mount-s3fs.sh /etc/cont-init.d/ZY-mount-s3fs
COPY files/setup-aws.sh /etc/cont-init.d/ZZ-setup-aws
COPY files/Rprofile /root/.Rprofile
COPY files/Rprofile /home/rstudio/.Rprofile

RUN mkdir /home/rstudio/notebooks
RUN chown rstudio /home/rstudio/notebooks

# An attempt to fix R sessions crashing when running Stan. Possible disk space issue.
# Mount /tmp to the host /tmp dir
VOLUME ["/tmp"]
