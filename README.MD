# Docker Management Container

The Docker Management Container includes a set of plugins and services that make it easier to build, test, deploy and manage infrastructure.

## Setup

Set service-specific tools, versions and configuration:

``` bash
vi .docker_build
```

## Image and Packages

### Image

| ARG              | Required | Default |
| ---------------- | -------- | ------- |
| CENTOS_VERSION   | no       | 8       |

### Image Config

Further packages to install can be specified

| ARG              | Required | Default |
| ---------------- | -------- | ------- |
| PACKAGES         | no       |         |

## Tools

Install needed Tools within Management Container

| ARG               | Required | Default |
| ----------------- | -------- | ------- |
| ANSIBLE_VERSION   | no       | latest  |
| DOCKER_VERSION    | no       | latest  |
| NOMAD_VERSION     | no       | latest  |
| KUBECTL_VERSION   | no       | latest  |
| HELM_VERSION      | no       | latest  |
| TERRAFORM_VERSION | no       | latest  |
| AZ_CLI_VERSION    | no       | latest  |
| AWS_CLI_VERSION   | no       | latest  |
| GCLOUD_VERSION    | no       | latest  |

## Tool Configuration / Add Specific extension

| ARG                  | Required | Default | Description                                                              |
| -------------------- | -------- | ------- | ------------------------------------------------------------------------ |
| PIP_REQUIREMENT      | no       |         | File which includes a list of pip packages to be installed               |
| ANSIBLE_REQUIREMENTS | no       |         | File which includes a list of ansible-galaxy collections to be installed |
| AZ_CLI_EXTENSIONS    | no       |         | List of azure-cli extenstions to be installed                            |

### System Configuration

## create Dockerfile from template with .docker_build configuration

``` bash
sh render.sh
```

## create container image

``` bash
export SERVICE=NAME
export TAG=1.0.0

docker build -t ${SERVICE}-mgmt:${TAG} .
```

### run mgmt container

``` bash
docker run -ti ${SERVICE}-mgmt:${TAG}
```

## Run Docker Container on local system

Install Docker Desktop, see [installation instructions](https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly).

### Mount local Volumes into Container

Configure WSL for right usage of volumes, see https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly, chapter: Create and modify the new WSL configuration file.

``` bash
/etc/wsl.conf

[automount]
root = /
options = "metadata"
```

#### Mount specific folder

``` bash
su root
mkdir /c

mount --bind /mnt/c /c
```

##### start container with local mount

``` bash
docker run -ti --env-file .docker_env -v /c/Users/USER/GITRepo:/root -w /root -ti ${SERVICE}-mgmt:${TAG}
```

behind proxy

``` bash
docker run -ti --env-file .docker_proxy_env -v /c/Users/USER/GITRepo:/root -w /root -ti ${SERVICE}-mgmt:${TAG}
```
