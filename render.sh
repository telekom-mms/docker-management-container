#!/bin/bash
# generate Dockerfile from template with build settings

# init stuff
SCRIPT_DIR=$(dirname $(readlink -f $0))
ENV_FILE="${SCRIPT_DIR}/.docker_build"

# function
render(){
  DOCKER_ARG=$(echo "${ARG}" | cut -d '=' -f1)
  VERSION=$(echo "${ARG}" | cut -d '=' -f2-)

  sedStr="s!ARG ${DOCKER_ARG}!ARG ${DOCKER_ARG}=${VERSION}!g;"

  echo "${sedStr}"
}

# main
while read ARG
do
  SED_ARG="${SED_ARG} $(render)"
done < $ENV_FILE

sed -r "${SED_ARG}" Dockerfile.template > Dockerfile
