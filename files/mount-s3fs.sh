#!/usr/bin/with-contenv bash

## Set defaults for environmental variables in case they are undefined
USER=${USER:=rstudio}
PASSWORD=${PASSWORD:=rstudio}
USERID=${USERID:=1000}
GROUPID=${GROUPID:=1000}
ROOT=${ROOT:=FALSE}
UMASK=${UMASK:=022}

# Mount notebooks via s3fs
if [[ ! -z "$AWS_ACCESS_KEY_ID" && ! -z "$AWS_SECRET_ACCESS_KEY" && ! -z "$NOTEBOOK_PATH" ]]; then
    echo "Mounting notebooks from: $NOTEBOOK_PATH"
    AWSACCESSKEYID=$AWS_ACCESS_KEY_ID AWSSECRETACCESSKEY=$AWS_SECRET_ACCESS_KEY s3fs $NOTEBOOK_PATH /home/$USER/notebooks \
                  -o use_cache="/tmp/s3fs_cache",use_sse,allow_other
fi
