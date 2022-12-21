# Docker Management Container

The Docker Management Container (or DMC for short) contains a number of plugins and services that are designed to make it easy to create, test, deploy and manage infrastructures. For more information also take a look at [T-Systems-MMS Blog](https://blog.t-systems-mms.com/tech-insights/manage-your-infrastructure-better-with-this-opensource-tool).

<!-- <picture>
  <source
    srcset="https://user-images.githubusercontent.com/3198961/186105564-3901aded-21f1-4191-b323-e943f49ea5ed.png"
    media="(prefers-color-scheme: dark)"
    width="30%" height="30%">
  <img width="30%" height="30%" src="">
</picture> -->

## How does the DMC work?

The DMC provides a Dockerfile template that creates the Dockerfile with the desired tools and versions through a file and script. This Dockerfile is then used for the actual build of the container. The Dockerfile itself does not need to be kept, but is created and discarded after the build of the Dockerfile.

The DMC uses the wakemeops as base setup, for more information about wakemeops look at the [docs](https://docs.wakemeops.com/).

### Try

For a quick overview and test of the DMC, we have created images based on the minimal and full examples that can be used directly.

``` bash
# minimal
docker run ghcr.io/t-systems-mms/dmc:min

# full
docker run ghcr.io/t-systems-mms/dmc:full
```

## Usage

### Setup and Configuration

Setup plugins, services, tools, versions and configuration over file with yaml syntax.

``` bash
touch build.yaml
```

#### Image

The DMC uses the wakemeops image as base image.

| ARG          | Required | Default | Description                                                                                |
| ------------ | -------- | ------- |------------------------------------------------------------------------------------------- |
| DISTRIBUTION | no       | ubuntu  | distribution that should be used, see also [wakemeops](https://hub.docker.com/u/wakemeops) |
| VERSION      | no       | latest  | specific version                                                                           |

#### Tools

Tools to be installed within the DMC.

| ARG                          | Required | Default                                                                            | Description                                                                                                                      |
| ---------------------------- | -------- | ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| WORKDIR                      | no       | /root                                                                              |                                                                                                                                  |
| PACKAGES                     | no       |                                                                                    | list of packages to be installed                                                                                                 |
| REPOSITORIES                 | no       |                                                                                    | further repositories that should be used, currently the following are defined withs defaults **_[hashicorp, docker, microsoft]_** |
| BINARIES                     | no       |                                                                                    | binaries that should be installed, currently the following are supported **_[github, google]_**                                   |
| REPOSITORIES_HASHICORP_GPG   | no       | `https://apt.releases.hashicorp.com/gpg`                                           |                                                                                                                                  |
| REPOSITORIES_HASHICORP_ENTRY | no       | `'https://apt.releases.hashicorp.com $(lsb_release -cs) main'`                     |                                                                                                                                  |                                                                          |                                                                                                                     |
| REPOSITORIES_DOCKER_GPG      | no       | `https://download.docker.com/linux/ubuntu/gpg`                                     |                                                                                                                                  |
| REPOSITORIES_DOCKER__ENTRY   | no       | `'https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'`             |                                                                                                                                  |                                                                                                                    |
| REPOSITORIES_MICROSOFT_GPG   | no       | `https://packages.microsoft.com/keys/microsoft.asc`                                |                                                                                                                                  |
| REPOSITORIES_MICROSOFT_ENTRY |          | `'https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main'`        |                                                                                                                                  |
| BINARIES_GITHUB_URI          | no       | `https://api.github.com/repos`                                                     |                                                                                                                                  |
| BINARIES_GOOGLE_URI          | no       | `https://packages.cloud.google.com/apt/dists/cloud-sdk/main/binary-arm64/Packages` |                                                                                                                                  |

#### Tool Config

Extension of installed tools.

| ARG          | Required | Default | Description                                                                                                                             |
| ------------ | -------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| WORKDIR      | no       | /root   |                                                                                                                                         |
| REQUIREMENTS | no       |         | requirements that should be installed for the used tools, currently the following are supported **_[pip, ansible(roles, collections)]_** |
| EXTENSIONS   | no       |         | extensions that should be installed for the used tools, currently the following are supported **_[az, google, helm]_**                   |

#### Post Build Config

System configuration and further setups to finish the DMC build afte.

| ARG                 | Required | Default | Description                                               |
| ------------------- | -------- | ------- | --------------------------------------------------------- |
| WORKDIR             | no       | /root   |                                                           |
| PROFILES            | no       |         | configuration for profile settings                        |
| POST_BUILD_COMMANDS | no       |         | commands to run after the image build to finish the setup |

### Build Dockerfile

To create the Dockerfile from Template you have simply to run the following steps.

1. create build.yaml with your needed settings
2. run the script `render.sh`
3. build Docker Image

`render.sh`

The build script which creates the `Dockerfile` from template with your settings from `build.yaml`

``` bash
sh render.sh .
```

### Build Image

``` bash
docker image build -t dmc:latest .
```

Examples for build within CI Pipelines can be found under [examples/pipeline](examples/pipeline).

### Run Image

#### local

To run the Docker Management Container your system must have Docker or Podman installed.

* Linux Client
* MacOS
* Docker Desktop for Windows or WSL2

``` bash
docker run -ti dmc:latest
```

##### mount volumes

You can mount your code or git repository into the container. This way you can work with your favorite editor and test the changes directly in the DMC.

Example:

``` bash
docker run -ti --env-file .docker_env -v${HOME}/git/service:/service -w /service dmc:latest
```

## Migration

With Version 2.0.0 there would be a breaking change in the configuration and usage of the DMC.
To support the migration we provide a script to migrate from the old .docker_build to the new build.yaml.

`migrate.sh`

``` bash
sh migrate.sh .
```

## Examples

Examples for the `build.yaml` could be found under [examples](examples):

* [minimal](examples/min_build.yaml)
* [full](examples/full_build.yaml)

## Others

Feedback, suggestions for improvement and expansion, and of course collaboration are expressly desired.
