#!/usr/bin/with-contenv bash

## Set defaults for environmental variables in case they are undefined
USER=${USER:=rstudio}
PASSWORD=${PASSWORD:=rstudio}
USERID=${USERID:=1000}
GROUPID=${GROUPID:=1000}
ROOT=${ROOT:=FALSE}
UMASK=${UMASK:=022}

# Create AWS credentials file
if [[ ! -z "$AWS_ACCESS_KEY_ID" && ! -z "$AWS_SECRET_ACCESS_KEY" ]]; then
    USER_HOME=$(getent passwd $USER | cut -f6 -d:)
    echo "Adding AWS credentials to profile file"
    echo "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> ${USER_HOME}/.profile
    echo "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> ${USER_HOME}/.profile
    chown ${USER}:${USER} ${USER_HOME}/.profile
    echo "Adding AWS credentials to .Renviron file"
    echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> ${USER_HOME}/.Renviron
    echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> ${USER_HOME}/.Renviron
    chown ${USER}:${USER} ${USER_HOME}/.Renviron
fi
