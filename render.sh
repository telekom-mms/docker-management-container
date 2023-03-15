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
DOCKERFILE_TEMPLATE_D="${SCRIPT_DIR}/template.d"
DOCKERFILE_TEMPLATE="${ENV_DIR}/Dockerfile.template"
DOCKERFILE="${ENV_DIR}/Dockerfile"

# function
build_template() {
  TEMPLATES=$(ls "${DOCKERFILE_TEMPLATE_D}")
  for TEMPLATE in ${TEMPLATES}
  do
    cat "${DOCKERFILE_TEMPLATE_D}/${TEMPLATE}" >> "${DOCKERFILE_TEMPLATE}"
    echo >> "${DOCKERFILE_TEMPLATE}"
  done
}

parse_yaml() {
  define_fs=$(echo @|tr @ '\034')

  local file=$1
  local s='[[:space:]]*'
  local w='[a-zA-Z0-9_.-]*'
  local fs=${define_fs}

  (
    sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |
        sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
            -e 's/\$/\\\$/g' \
            -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
            -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
        awk -F"$fs" '{
        indent = length($1)/2;
        if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
          if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            if (vname[1]) {
              printf("%s=%s\n", vname[0], vname[1]);
            }
            printf("%s%s%s=%s\n", vn, $2, conj[indent-1], $3);
          }
        }' |
        sed -e 's/_=/=/g' |
        sed -e 's/_\./__/g' |
        awk '{ print }'
  ) <"$file"
}

# main
echo > "${DOCKERFILE}"
build_template
parse_yaml "${ENV_FILE}" > "${BUILD_FILE}"

KEYS=$(cut -d '=' -f1 "${BUILD_FILE}" | sort -u)

## generate ARG=VALUE for replacement
for KEY in ${KEYS}
do
  if [ "$(grep -c "^${KEY}=" "${BUILD_FILE}")" -gt 1 ]; then
    VALUE=$(grep "^${KEY}=" "${BUILD_FILE}" | cut -d '=' -f2- | sort -u | tr '\n' ';')
  else
    VALUE=$(grep "^${KEY}=" "${BUILD_FILE}" | cut -d '=' -f2- | sort -u | tr -d '\n')
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
    SED_APPEND_KEY_ARG=$(echo "${SED_APPEND_ARGS}" | tr '#' '\n' | sed -n "s/${SED_APPEND_KEY}=/ARG /p" | sed 's/$/\\n/g' | tr -d '\n')


    sed -i "/ARG ${SED_APPEND_KEY}/a ${SED_APPEND_KEY_ARG}" "${DOCKERFILE}"
  done
fi

## remove helper files
rm "${BUILD_FILE}" "${DOCKERFILE_TEMPLATE}"
