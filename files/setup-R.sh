#!/usr/bin/with-contenv bash

## Set defaults for environmental variables in case they are undefined
USER=${USER:=rstudio}
PASSWORD=${PASSWORD:=rstudio}
USERID=${USERID:=1000}
GROUPID=${GROUPID:=1000}
ROOT=${ROOT:=FALSE}
UMASK=${UMASK:=022}

# Copy over Makevars

ROOT_MAKEVARS="/root/.R/Makevars"
ROOT_RPROFILE="/root/.Rprofile"
ROOT_RENVIRON="/root/.Renviron"

if [[ -f ${ROOT_MAKEVARS} ]]; then
    USER_HOME=$(getent passwd $USER | cut -f6 -d:)
    echo "Copying over R Makevars from root"
    mkdir -p ${USER_HOME}/.R
    cp ${ROOT_MAKEVARS} ${USER_HOME}/.R/
    chown -R ${USER}:${USER} ${USER_HOME}/.R
fi


if [[ -f ${ROOT_RPROFILE} ]]; then
    USER_HOME=$(getent passwd $USER | cut -f6 -d:)
    echo "Copying over R Makevars from root"
    cp ${ROOT_RPROFILE} ${USER_HOME}/
    chown ${USER}:${USER} ${USER_HOME}/.Rprofile
fi


if [[ -f ${ROOT_RENVIRON} ]]; then
    USER_HOME=$(getent passwd $USER | cut -f6 -d:)
    echo "Copying over R Environ from root"
    cp ${ROOT_RENVIRON} ${USER_HOME}/
    chown ${USER}:${USER} ${USER_HOME}/.Renviron
fi
