#!/bin/sh
# script to migrate build settings from version 1.x > 2 and to remove old files

# init stuff
if [ $# -ne 1 ]; then
  printf "no directory provided\n\n"
  echo "Usage: sh migrate.sh <DIRECTORY>"
  exit 2
fi

ENV_DIR=${1-$(dirname "$(readlink -f "$0")")}
ENV_FILE="${ENV_DIR}/build.yaml"
OLD_ENV_FILE="${ENV_DIR}/.docker_build"

PACKAGES="PACKAGES|ANSIBLE_VERSION|DOCKER_VERSION|NOMAD_VERSION|CONSUL_VERSION|KUBECTL_VERSION|HELM_VERSION|TERRAFORM_VERSION|AZ_CLI_VERSION|AWS_CLI_VERSION"
BINARIES="GCLOUD_VERSION|GITHUB_BINARIES"
REQUIREMENTS="PIP_REQUIREMENTS|ANSIBLE_REQUIREMENTS"
EXTENSIONS="AZ_CLI_EXTENSIONS|HELM_EXTENSIONS"

## funtion
migrate() {
  ## packages
  SEARCH_PACKAGES=$(grep -E ${PACKAGES} "${OLD_ENV_FILE}" | sed 's/"//g' | sed 's/PACKAGES=//g')
  if [ "${SEARCH_PACKAGES}" != "" ]; then
    echo "packages:" > "${ENV_FILE}"

    for SEARCH_PACKAGE in ${SEARCH_PACKAGES}
    do
      PACKAGE_RESULT=$(echo "${SEARCH_PACKAGE}" | sed 's/_VERSION//g' |  sed 's/=latest//g' | awk '{print tolower($0)}')
      PACKAGE=$(echo "${PACKAGE_RESULT}" | sed 's/docker/docker-ce/g' | sed 's/az_cli/azure-cli/g' | sed 's/aws_cli/awscli/g')
      echo "  - ${PACKAGE}" >> "${ENV_FILE}"
    done
  fi

  ## repositories
  SEARCH_REPOSITORIES=$(grep -E "azure-cli|docker-ce|nomad|consul" "${ENV_FILE}" | sed 's/-\ //g')
  if [ "${SEARCH_REPOSITORIES}" != "" ]; then
    echo "repositories:" >> "${ENV_FILE}"

    for SEARCH_REPOSITORY in ${SEARCH_REPOSITORIES}
    do
      REPOSITORY=$(echo "${SEARCH_REPOSITORY}" | sed 's/azure-cli/microsoft/g' | sed 's/docker-ce/docker/g' | sed 's/nomad/hashicorp/g' | sed 's/consul/hashicorp/g')
      echo "  - ${REPOSITORY}" >> "${ENV_FILE}"
    done
  fi

  ## binaries
  SEARCH_BINARIES=$(grep -E ${BINARIES} "${OLD_ENV_FILE}")
  GITHUB_COUNT=0

  if [ "${SEARCH_BINARIES}" != "" ]; then
    echo "binaries:" >> "${ENV_FILE}"

    for SEARCH_BINARY in ${SEARCH_BINARIES}
    do
      BINARY_RESULT=$(echo "${SEARCH_BINARY}" | sed s/GITHUB_BINARIES=//g | sed 's/"//g')

      if [ "$(echo "${BINARY_RESULT}" | grep -i gcloud)" != "" ]; then
        echo "  google:" >> "${ENV_FILE}"
        BINARY=$(echo "${BINARY_RESULT}" | sed 's/_VERSION//g' | sed 's/=latest//g' |  awk '{print tolower($0)}' | sed 's/gcloud/google-cloud-cli/g')
        echo  "    - ${BINARY}" >> "${ENV_FILE}"
      elif [ ${GITHUB_COUNT} -lt 1 ]; then
        echo "  github:" >> "${ENV_FILE}"
        GITHUB_COUNT=1
        BINARY=$(echo "${BINARY_RESULT}" | sed 's/\/releases\/latest//g' | sed 's/:/=/g' | awk -F '/releases/' '{print $1"="$2}' | awk -F '=' '{print $1"="$3"="$2}' | sed 's/==/=/g')
        echo  "    - ${BINARY}" >> "${ENV_FILE}"
      else
        BINARY=$(echo "${BINARY_RESULT}" | sed 's/\/releases\/latest//g' | sed 's/:/=/g' | awk -F '/releases/' '{print $1"="$2}' | awk -F '=' '{print $1"="$3"="$2}' | sed 's/==/=/g')
        echo  "    - ${BINARY}" >> "${ENV_FILE}"
      fi
    done
  fi

  ## requirements
  SEARCH_REQUIREMENTS=$(grep -E ${REQUIREMENTS} "${OLD_ENV_FILE}")
  if [ "${SEARCH_REQUIREMENTS}" != "" ]; then
    echo "requirements:" >> "${ENV_FILE}"
    REQUIREMENT_RESULT=$(echo "${SEARCH_REQUIREMENTS}" | tr ' ' '\n')

    for REQUIREMENT in ${REQUIREMENT_RESULT}
    do
      REQ=$(echo "${REQUIREMENT}" | sed 's/_REQUIREMENTS.*//g' |  awk '{print tolower($0)}')
      REQ_LIST=$(echo "${REQUIREMENT}" | sed 's/.*_REQUIREMENTS=//g' | sed 's/"//g')
      echo "  ${REQ}:" >> "${ENV_FILE}"
      if [ "${REQ}" = "pip" ]; then
        sed 's/==/=/g' "${ENV_DIR}/${REQ_LIST}" | while IFS= read -r REQ_CONTENT
        do
          echo "    - ${REQ_CONTENT}" >> "${ENV_FILE}"
        done
        elif [ "${REQ}" = "ansible" ]; then
        for REQ_CONTENT in $(sed 's/^#.*//g' "${ENV_DIR}/${REQ_LIST}" | tr -d '-' | tr -d ' ' | sed 's/name:/ /g' | sed 's/version:/=/g' | sed '/^.*:/ s/./#&/' | tr -d '\n' | tr '#' '\n')
        do
          if [ "$(echo "${REQ_CONTENT}" | grep -E "^roles|collections")" != "" ]; then
            echo "    ${REQ_CONTENT}" >> "${ENV_FILE}"
          else
            echo "      - ${REQ_CONTENT}" >> "${ENV_FILE}"
          fi
        done
      fi

      rm "${ENV_DIR}/${REQ_LIST}"
    done
  fi

  ## extensions
  SEARCH_EXTENSIONS=$(grep -E "${EXTENSIONS}" "${OLD_ENV_FILE}")

  if [ "${SEARCH_EXTENSIONS}" != "" ]; then
      echo "extensions:" >> "${ENV_FILE}"

      EXTENSION_RESULT=$(echo "${SEARCH_EXTENSIONS}" | tr ' ' '\n' | sed 's/"//g' | sed 's/=/\n/g')
      for EXTENSION in ${EXTENSION_RESULT}
      do
        if [ "$(echo "${EXTENSION}" | grep -E "AZ_CLI|HELM" )" != "" ]; then
          echo "  $(echo "${EXTENSION}" | sed 's/_EXTENSIONS//g' | sed 's/AZ_CLI/az/g' | awk '{print tolower($0)}'):" >> "${ENV_FILE}"
        else
          echo "    - ${EXTENSION}" >> "${ENV_FILE}"
        fi
      done
  fi

  rm "${OLD_ENV_FILE}"
}

## main
migrate
