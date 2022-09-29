# Docker Management Container

The Docker Management Container includes a set of plugins and services that make it easier to build, test, deploy and manage infrastructure.

<picture>
  <source
    srcset="https://user-images.githubusercontent.com/3198961/186105564-3901aded-21f1-4191-b323-e943f49ea5ed.png"
    media="(prefers-color-scheme: dark)"
    width="30%" height="30%">
  <img width="30%" height="30%" src="https://user-images.githubusercontent.com/3198961/186105473-eab8c428-4a19-474d-b391-e2410383d05d.png">
</picture>

## Setup

Set service-specific tools, versions and configuration:

``` bash
vi .docker_build
```

## Image and Packages

### Image

| ARG                | Required | Default |
| ------------------ | -------- | ------- |
| ROCKYLINUX_VERSION | no       | 8       |

### Image Config

python version can be defined

| ARG              | Required | Default |
| ---------------- | -------- | ------- |
| PYTHON_VERSION   | no       | 39       |

Further packages to install can be specified

| ARG              | Required | Default |
| ---------------- | -------- | ------- |
| PACKAGES         | no       |         |

## Tools

Install needed Tools within Management Container

| ARG               | Required | Default | Description                      |
| ----------------- | -------- | ------- | -------------------------------- |
| ANSIBLE_VERSION   | no       | latest  |                                  |
| DOCKER_VERSION    | no       | latest  |                                  |
| NOMAD_VERSION     | no       | latest  |                                  |
| CONSUL_VERSION    | no       | latest  |                                  |
| KUBECTL_VERSION   | no       | latest  |                                  |
| HELM_VERSION      | no       | latest  |                                  |
| TERRAFORM_VERSION | no       | latest  |                                  |
| AZ_CLI_VERSION    | no       | latest  |                                  |
| AWS_CLI_VERSION   | no       | latest  |                                  |
| GCLOUD_VERSION    | no       | latest  |                                  |
| GITHUB_BINARIES   | no       | latest  | List of packages to be installed, format is [package binary name]:[package binary format] |

## Tool Configuration / Add Specific extension

| ARG                  | Required | Default | Description                                                              |
| -------------------- | -------- | ------- | ------------------------------------------------------------------------ |
| PIP_REQUIREMENTS     | no       |         | File which includes a list of pip packages to be installed               |
| ANSIBLE_REQUIREMENTS | no       |         | File which includes a list of ansible-galaxy collections to be installed |
| AZ_CLI_EXTENSIONS    | no       |         | List of azure-cli extenstions to be installed                            |

### System Configuration

## create Dockerfile from template with .docker_build configuration

``` bash
sh render.sh .
```

## create container image

``` bash
export DMC="service-mgmt-dmc:1.0.0"

docker build -t ${DMC} .
```

## Pipelines

Examples for build within Pipelines can be found under [examples/pipeline](examples/pipeline).

## Local Usage

### run DMC

To run the Docker Management Container your system must have Docker or Podman installed.

* Linux Client
* MacOS
* Docker Desktop for Windows or WSL2

``` bash
docker run -ti ${DMC}
```

### mount volumes

You can mount your code or git repository into the container. This way you can work with your favorite editor and test the changes directly in the DMC.

Example:

``` bash
docker run -ti --env-file .docker_env -v${HOME}/git/service:/service -w /service ${DMC}
```
