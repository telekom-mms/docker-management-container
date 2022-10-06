###################################### Image ######################################
ARG DISTRIBUTION=ubuntu
ARG VERSION=latest

## build Image
FROM wakemeops/${DISTRIBUTION}:${VERSION}

SHELL ["/bin/bash", "-c"]

# default packages to install
RUN apt-get update && \
    install_packages \
    apt-utils \
    software-properties-common \
    curl \
    wget \
    jq \
    unzip \
    vim \
    git \
    bash-completion \
    findutils \
    python3\
    python3-pip && \
    apt-get clean all

###################################### Tools ######################################
ARG WORKDIR=/root
ARG PACKAGES="ansible docker kubectl helm terraform=1.1.7 nomad consul azure-cli awscli telnet "
ARG REPOSITORIES="hashicorp microsoft "
ARG BINARIES="github google "

ARG REPOSITORIES_HASHICORP_GPG="https://apt.releases.hashicorp.com/gpg"
ARG REPOSITORIES_HASHICORP_URI="https://apt.releases.hashicorp.com"
ARG REPOSITORIES_MICROSOFT_GPG="https://packages.microsoft.com/keys/microsoft.asc"
ARG REPOSITORIES_MICROSOFT_URI="https://packages.microsoft.com/repos/azure-cli/"

ARG BINARIES_GITHUB_URI="https://api.github.com/repos"
ARG BINARIES_GITHUB="remotemobprogramming/mob=linux_amd64=v3.2.0 derailed/k9s=Linux_x86_64 "
ARG BINARIES_GOOGLE_URI="https://packages.cloud.google.com/apt/dists/cloud-sdk/main/binary-arm64/Packages"
ARG BINARIES_GOOGLE="google-cloud-cli=403.0.0-0 "

WORKDIR ${WORKDIR}

## repositories
RUN test -n "${REPOSITORIES}" && \
    for REPOSITORY in ${REPOSITORIES}; do declare -u REPO=${REPOSITORY} && REPO_GPG=$(eval "echo \$REPOSITORIES_${REPO}_GPG") && REPO_URI=$(eval "echo \$REPOSITORIES_${REPO}_URI") && \
    curl -fsSL ${REPO_GPG} | gpg --dearmor | tee /etc/apt/trusted.gpg.d/${REPOSITORY}.gpg > /dev/null && apt-add-repository "deb [arch=amd64] ${REPO_URI} $(lsb_release -cs) main"; done

## packages
RUN test -n "${PACKAGES}" && \
    install_packages ${PACKAGES}

## binaries
RUN test -n "${BINARIES}" && \
    for BINARY in ${BINARIES}; do declare -u BINARY_REPO=${BINARY} && BINARY_URI=$(eval "echo \$BINARIES_${BINARY_REPO}_URI") && BINARY_PACKAGES=$(eval "echo \$BINARIES_${BINARY_REPO}") && \
    if [ "${BINARY_REPO}" = "GITHUB" ]; then for BINARY_PACKAGE in ${BINARY_PACKAGES}; do BINARY_PACKAGE_URI=$(echo ${BINARY_URI}/${BINARY_PACKAGE} | awk -F '=' '{ if (!$3) {version="/latest"}; printf("%s/releases%s", $1, version)}')  && \
    BINARY_PACKAGE_VERSION=$(echo ${BINARY_PACKAGE} | awk -F '=' '{print $3".*"$2".tar.gz"}') && \
    BINARY_PACKAGE_URL=$(curl -fsSL ${BINARY_PACKAGE_URI} | grep -Po '"browser_download_url": "\K.*?(?=\")' | grep -P ${BINARY_PACKAGE_VERSION}) && \
    mkdir -p ./github && curl -SsL --retry 5 "${BINARY_PACKAGE_URL}" | tar xz -C ./github && \
    chmod -R +x ./github/* && mv ./github/* /usr/local/bin/; done; fi && \
    if [ "${BINARY_REPO}" = "GOOGLE" ]; then for BINARY_PACKAGE in ${BINARY_PACKAGES}; do BINARY_PACKAGE_VERSION=$(curl -fSsL ${BINARY_URI} | grep -P $(echo ${BINARY_PACKAGE} | sed 's/=/.*/g') | cut -d '_' -f2 | sort -n | grep $(echo ${BINARY_PACKAGE} | cut -d '=' -f2) | tail -n1 | cut -d '-' -f1) && \
    BINARY_PACKAGE_URI=$(echo "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$(echo ${BINARY_PACKAGE} | cut -d '=' -f1)-${BINARY_PACKAGE_VERSION}-linux-x86_64.tar.gz") && \
    mkdir -p ./google && curl -SsL --retry 5 ${BINARY_PACKAGE_URI} | tar xz -C ./google && \
    chmod -R +x ./google/* && \
    sh ./google/*/install.sh -q; done; fi; done

###################################### Tool Config ################################
ARG WORKDIR=/root
ARG REQUIREMENTS="pip ansible "
ARG EXTENSIONS="az helm "

ARG REQUIREMENTS_PIP="packaging requests[security] xmltodict azure-cli-core=2.34.0 azure-common=1.1.11 "
ARG REQUIREMENTS_ANSIBLE_ROLES="t_systems_mms.grafana "
ARG REQUIREMENTS_ANSIBLE_COLLECTIONS="t_systems_mms.acme=2.3.1 t_systems_mms.icinga_director=1.28.0 "

ARG EXTENSIONS_AZ="front-door=1.0.15 "
ARG EXTENSIONS_HELM="https://github.com/databus23/helm-diff=3.5.0 https://github.com/jkroepke/helm-secrets "

WORKDIR ${WORKDIR}

## requirements
RUN test -n "${REQUIREMENTS}" && \
    for REQUIREMENT in ${REQUIREMENTS}; do declare -u REQ=${REQUIREMENT} && REQUIREMENTS_REQ=$(eval "echo \$REQUIREMENTS_${REQ}") && \
    if [ "${REQ}" = "PIP" ]; then for REQUIREMENT_REQ in ${REQUIREMENTS_REQ}; do pip3 install $(echo ${REQUIREMENT_REQ} | sed 's/=/==/g'); done; fi && \
    if [ "${REQ}" = "ANSIBLE" ]; then for REQUIREMENT_REQ in ${REQUIREMENTS_ANSIBLE_ROLES}; do ansible-galaxy install $(echo ${REQUIREMENT_REQ} | sed 's/=/,/g'); done && \
    for REQUIREMENT_REQ in ${REQUIREMENTS_ANSIBLE_COLLECTIONS}; do ansible-galaxy collection install $(echo ${REQUIREMENT_REQ} | sed 's/=/:/g'); done; fi; done

## extensions
RUN test -n "${EXTENSIONS}" && \
    for EXTENSION in ${EXTENSIONS}; do declare -u EXT=${EXTENSION} && EXTENSIONS_EXT=$(eval "echo \$EXTENSIONS_${EXT}") && \
    if [ "${EXT}" = "AZ" ]; then for EXTENSION_EXT in ${EXTENSIONS_EXT}; do az extension add -y --name $(echo ${EXTENSION_EXT} | sed 's/=/ --version /g'); done; fi && \
    if [ "${EXT}" = "HELM" ]; then for EXTENSION_EXT in ${EXTENSIONS_EXT}; do helm plugin install $(echo ${EXTENSION_EXT} | sed 's/=/ --version=/g'); done; fi; done

###################################### Config #####################################
ARG WORKDIR=/root

WORKDIR ${WORKDIR}
CMD ["/bin/bash"]
