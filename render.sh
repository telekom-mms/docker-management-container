#!/bin/bash
# generate Dockerfile from template with build settings

# init stuff
if [ -z $1 ]; then
  printf "no directory provided\n\n"
  echo "Usage: sh render.sh <DIRECTORY>"
  exit 2
fi
SCRIPT_DIR=$(dirname $(readlink -f $0))
ENV_DIR=${1-SCRIPT_DIR}
ENV_FILE="${ENV_DIR}/.docker_build"

# function
render(){
  DOCKER_ARG=$(echo "${ARG}" | cut -d '=' -f1)
  VERSION=$(echo "${ARG}" | cut -d '=' -f2-)

  sedStr="s!ARG ${DOCKER_ARG}.*!ARG ${DOCKER_ARG}=${VERSION}!g;"

  echo "${sedStr}"
}

# main
while read ARG
do
  SED_ARG="${SED_ARG} $(render)"
done < $ENV_FILE

sed -r "${SED_ARG}" ${SCRIPT_DIR}/Dockerfile.template > ${ENV_DIR}/Dockerfile
