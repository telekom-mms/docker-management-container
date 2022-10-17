#!/bin/sh
# generate Dockerfile from template with build settings

# init stuff
if [ $# -ne 1 ]; then
  printf "no directory provided\n\n"
  echo "Usage: sh render.sh <DIRECTORY>"
  exit 2
fi
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
ENV_DIR=${1-SCRIPT_DIR}
ENV_FILE="${ENV_DIR}/build.yaml"
BUILD_FILE="${ENV_DIR}/.build"

# function
parse_yaml() {
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|,$s\]$s\$|]|" \
      -e ":1;s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1  - \4|;t1" \
      -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1  - \3|;p" $1 | \
  sed -ne "s|,$s}$s\$|}|" \
      -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1  \3: \4|;t1" \
      -e    "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1  \2|;p" | \
  sed -ne "s|^\($s\):|\1|" \
      -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p" \
      -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|p" \
      -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" | \
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
    if(length($2)== 0){  vname[indent]= ++idx[indent] };
    if (length($3) > 0) {
        vn="";
        name="";
        subname="";
        for (i=0; i<indent; i++) {
          if (vname[2]) {
            name=(vname[1])
            subname=("_")(vname[1])
          }
          if (vname[3]) {
            subname=("_")(vname[1])("_")(vname[2])
          }
          vn=(vn)(vname[i]) }

        if (name) {printf("%s=%s\n", vname[0], name)};
        printf("%s%s=%s\n", vname[0], subname, $3);
    }
  }'
}

render(){
  echo > "${ENV_DIR}/Dockerfile"
  parse_yaml ${ENV_FILE} > ${BUILD_FILE}

  KEYS=$(cat ${BUILD_FILE} | cut -d '=' -f1 | sort -u)

  for KEY in ${KEYS}
  do
    VALUE=$(cat ${BUILD_FILE} | grep -w ${KEY} | cut -d '=' -f2- | sort -u | tr '\n' ' ')
    ARG=$(echo ${KEY} | awk '{print toupper($0)}')

    sedStr="${sedStr} s!ARG \<${ARG}\>!ARG ${ARG}=\"${VALUE}\"!g;"
  done

  echo "${sedStr}"
  rm ${BUILD_FILE}
}

# main
SED_ARG=$(render)

sed -r "${SED_ARG}" "${SCRIPT_DIR}/Dockerfile.template" > "${ENV_DIR}/Dockerfile"
