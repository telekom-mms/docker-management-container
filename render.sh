#!/bin/bash
# generate Dockerfile from template with build settings

# init stuff
if [ $# -ne 1 ]; then
  printf "no directory provided\n\n"
  echo "Usage: sh render.sh <DIRECTORY>"
  exit 2
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
ENV_DIR="${1-SCRIPT_DIR}"
ENV_FILE="${ENV_DIR}/build.yaml"
BUILD_FILE="${ENV_DIR}/.build"
DOCKERFILE_TEMPLATE="${SCRIPT_DIR}/Dockerfile.template"
DOCKERFILE="${ENV_DIR}/Dockerfile"

# function
parse_yaml() {
  define_fs=$(echo @|tr @ '\034')
  local s='[[:space:]]*' w='[.a-zA-Z0-9_]*' fs=${define_fs}
  sed -ne "s|,${s}\]${s}\$|]|" \
      -e ":1;s|^\(${s}\)\(${w}\)${s}:$s\[${s}\(.*\)${s},${s}\(.*\)${s}\]|\1\2: [\3]\n\1  - \4|;t1" \
      -e "s|^\(${s}\)\(${w}\)${s}:$s\[${s}\(.*\)${s}\]|\1\2:\n\1  - \3|;p" "$1" | \
  sed -ne "s|,${s}}${s}\$|}|" \
      -e ":1;s|^\(${s}\)-${s}{${s}\(.*\)${s},${s}\(${w}\)${s}:${s}\(.*\)${s}}|\1- {\2}\n\1  \3: \4|;t1" \
      -e    "s|^\(${s}\)-${s}{${s}\(.*\)${s}}|\1-\n\1  \2|;p" | \
  sed -ne "s|^\(${s}\):|\1|" \
      -e "s|^\(${s}\)-${s}[\"']\(.*\)[\"']${s}\$|\1${fs}${fs}\2|p" \
      -e "s|^\(${s}\)-${s}\(.*\)${s}\$|\1${fs}${fs}\2|p" \
      -e "s|^\(${s}\)\(${w}\)${s}:${s}[\"']\(.*\)[\"']${s}\$|\1${fs}\2${fs}\3|p" \
      -e "s|^\(${s}\)\(${w}\)${s}:${s}\(.*\)${s}\$|\1${fs}\2${fs}\3|p" | \
  awk -F"${fs}" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
    if(length($2)== 0){  vname[indent]= ++idx[indent] };
    if (length($3) > 0) {
        name="";
        subname="";
        value=$3;

        if ($3 == "{}" || $3 == "[]") {
          value="default"
        }

        for (i=0; i<indent; i++) {
          if (vname[2] || value == "default") {
            name=(vname[1])
            subname=("_")(vname[1])
          }
          if (vname[2] != i || vname[3]) {
            subname=("_")(vname[1])("_")(vname[2])
          }
        }

        if (name) {printf("%s=%s\n", vname[0], name)};
        if (value != "default") {printf("%s%s=%s\n", vname[0], subname, value)};
    }
  }'
}

# main
echo > "${DOCKERFILE}"
parse_yaml "${ENV_FILE}" > "${BUILD_FILE}"

KEYS=$(cut -d '=' -f1 "${BUILD_FILE}" | sort -u)

## generate ARG=VALUE for replacement
for KEY in ${KEYS}
do
  if [ $(grep -wc "${KEY}" "${BUILD_FILE}") -gt 1 ]; then
    VALUE=$(grep -w "${KEY}" "${BUILD_FILE}" | cut -d '=' -f2- | sort -u | tr '\n' ';')
  else
    VALUE=$(grep -w "${KEY}" "${BUILD_FILE}" | cut -d '=' -f2- | sort -u | tr -d '\n')
  fi
  ARG=$(echo "${KEY}" | awk '{print toupper($0)}')

  if [ "$(grep -cw "ARG ${ARG}" "${DOCKERFILE_TEMPLATE}")" -eq 0 ]; then
    ARG_N=$(echo "${ARG}" | awk -F '_' '{print $1"_N"}')
    SED_APPEND_ARGS="${SED_APPEND_ARGS}#${ARG_N}=${ARG}=\"${VALUE}\""
  else
    SED_REPLACE="${SED_REPLACE} s!ARG \<${ARG}\>.*\$!ARG ${ARG}=\"${VALUE}\"!g;"
  fi
done

## replace ARG
sed -r "${SED_REPLACE}" "${DOCKERFILE_TEMPLATE}" > "${DOCKERFILE}"

## append ARG
if [ "${SED_APPEND_ARGS}" != "" ]; then
  SED_APPEND_KEYS=$(echo "$SED_APPEND_ARGS" |  tr '#' '\n' | cut -d '=' -f1 | sort -u | xargs)

  for SED_APPEND_KEY in ${SED_APPEND_KEYS}; do
    SED_APPEND_KEY_ARG=$(echo "${SED_APPEND_ARGS}" |  tr '#' '\n' | sed -n "s/${SED_APPEND_KEY}=/ARG /p" | sed 's/$/\\n/g' | tr -d '\n')


    sed -i "/ARG ${SED_APPEND_KEY}/a ${SED_APPEND_KEY_ARG}" "${DOCKERFILE}"
  done
fi

#rm "${BUILD_FILE}"
