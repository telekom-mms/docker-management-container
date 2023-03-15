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

The DMC provides a Dockerfile template (from modular setup) that creates the Dockerfile with the desired tools and versions through a file and script. This Dockerfile is then used for the actual build of the container. The Dockerfile itself does not need to be kept, but is created and discarded after the build of the Dockerfile.

The DMC uses the wakemeops as base setup, for more information about wakemeops look at the [docs](https://docs.wakemeops.com/).

### Try

For a quick overview and test of the DMC, we have created images based on the [minimal](examples/min_build.yaml) and [full](examples/full_build.yaml) examples that can be used directly.

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

| ARG          | Required | Default | Description                                                                                | build.yaml use default | build.yaml setup custom |
| ------------ | -------- | ------- |------------------------------------------------------------------------------------------- | ---------------------- | ----------------------- |
| DISTRIBUTION | no       | ubuntu  | distribution that should be used, see also [wakemeops](https://hub.docker.com/u/wakemeops) |                        | distribution: debian    |
| VERSION      | no       | latest  | specific version                                                                           |                        | version: buster         |

#### Base

Basic Setup of the DMC.

| ENV       | Default |
| --------- | ------- |
| CONTAINER | true    |

#### Tools

Tools to be installed within the DMC.

| ARG                          | Required | Default                                                                            | Description                                                                                                                      | build.yaml use default                                                                                                                                                 | build.yaml setup custom                                                                                                                                                                                                        |
| ---------------------------- | -------- | ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| WORKDIR                      | no       | /root                                                                              |                                                                                                                                  |                                                                                                                                                                        |                                                                                                                                                                                                                                |
| PACKAGES                     | no       |                                                                                    | list of packages to be installed                                                                                                 |                                                                                                                                                                        | packages:<br>&nbsp;&nbsp;- ansible<br>&nbsp;&nbsp;- docker-ce<br>&nbsp;&nbsp;- helm<br>&nbsp;&nbsp;- kubectl                                                                                                                   |
| REPOSITORIES                 | no       |                                                                                    | further repositories that should be used, currently the following are defined with defaults **_[hashicorp, docker, microsoft]_** | repositories:<br>&nbsp;&nbsp;docker: {}<br>&nbsp;&nbsp;microsoft: {}<br>&nbsp;&nbsp;hashicorp: {}                                                                      | repositories:<br>&nbsp;&nbsp;mongodb:<br>&nbsp;&nbsp;&nbsp;&nbsp;gpg: https://www.mongodb.org/static/pgp/server-6.0.asc<br>&nbsp;&nbsp;&nbsp;&nbsp;entry: https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse |
| BINARIES                     | no       |                                                                                    | binaries that should be installed, currently the following are supported **_[github, google]                                     | github:<br>&nbsp;&nbsp;- remotemobprogramming/mob=linux_amd64=v3.2.0<br>&nbsp;&nbsp;- derailed/k9s=Linux_x86_64<br>google:<br>&nbsp;&nbsp;- google-cloud-cli           |                                                                                                                                                                                                                                |
| REPOSITORIES_HASHICORP_GPG   | no       | `https://apt.releases.hashicorp.com/gpg`                                           | default                                                                                                                          |                                                                                                                                                                        |                                                                                                                                                                                                                                |
| REPOSITORIES_HASHICORP_ENTRY | no       | `'https://apt.releases.hashicorp.com $(lsb_release -cs) main'`                     | default                                                                                                                          |                                                                                                                                                                        |                                                                                                                                                                                                                                |
| REPOSITORIES_DOCKER_GPG      | no       | `https://download.docker.com/linux/ubuntu/gpg`                                     | default                                                                                                                          |                                                                                                                                                                        |                                                                                                                                                                                                                                |
| REPOSITORIES_DOCKER__ENTRY   | no       | `'https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'`             | default                                                                                                                          |                                                                                                                                                                        |                                                                                                                                                                                                                                |
| REPOSITORIES_MICROSOFT_GPG   | no       | `https://packages.microsoft.com/keys/microsoft.asc`                                | default                                                                                                                          |                                                                                                                                                                        |                                                                                                                                                                                                                                |
| REPOSITORIES_MICROSOFT_ENTRY |          | `'https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main'`        | default                                                                                                                          |                                                                                                                                                                        |                                                                                                                                                                                                                                |
| BINARIES_GITHUB_URI          | no       | `https://api.github.com/repos`                                                     | default                                                                                                                          |                                                                                                                                                                        |                                                                                                                                                                                                                                |
| BINARIES_GOOGLE_URI          | no       | `https://packages.cloud.google.com/apt/dists/cloud-sdk/main/binary-arm64/Packages` | default                                                                                                                          |                                                                                                                                                                        |                                                                                                                                                                                                                                |

#### Tool Config

Extension of installed tools.

| ARG          | Required | Default | Description                                                                                                                              | build.yaml use default                                                                                                                                                                                                                                                                                                                                                                                                                                                       | build.yaml setup custom |
| ------------ | -------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| WORKDIR      | no       | /root   |                                                                                                                                          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |                         |
| REQUIREMENTS | no       |         | requirements that should be installed for the used tools, currently the following are supported **_[pip, ansible(roles, collections)]_** | requirements:<br>&nbsp;&nbsp;pip:<br>&nbsp;&nbsp;&nbsp;&nbsp;packages:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- awsume<br>&nbsp;&nbsp;&nbsp;&nbsp;requirements:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt<br>&nbsp;&nbsp;ansible:<br>&nbsp;&nbsp;&nbsp;&nbsp;roles:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- t_systems_mms.grafana<br>&nbsp;&nbsp;&nbsp;&nbsp;collections:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- t_systems_mms.acme=2.3.1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- t_systems_mms.icinga_director=1.28.0<br>&nbsp;&nbsp;&nbsp;&nbsp;requirements:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- https://github.com/T-Systems-MMS/ansible-role-maxscale/blob/master/requirements.yml |                         |
| EXTENSIONS   | no       |         | extensions that should be installed for the used tools, currently the following are supported **_[az, google, helm]_**                   | extensions:<br>&nbsp;&nbsp;az:<br>&nbsp;&nbsp;&nbsp;&nbsp;- front-door=1.0.15<br>&nbsp;&nbsp;google:<br>&nbsp;&nbsp;&nbsp;&nbsp;- gsutil<br>&nbsp;&nbsp;&nbsp;&nbsp;- gke-gcloud-auth-plugin<br>&nbsp;&nbsp;&nbsp;&nbsp;- kubectl<br>&nbsp;&nbsp;helm:<br>&nbsp;&nbsp;&nbsp;&nbsp;- https://github.com/databus23/helm-diff=3.5.0<br>&nbsp;&nbsp;&nbsp;&nbsp;- https://github.com/jkroepke/helm-secrets                                                                       |                         |

#### Post Build Config

System configuration and further setups to finish the DMC build.

| ARG                 | Required | Default | Description                                               | build.yaml use default | build.yaml setup custom                                                                                                                                |
| ------------------- | -------- | ------- | --------------------------------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| WORKDIR             | no       | /root   |                                                           |                        |                                                                                                                                                        |
| PROFILES            | no       |         | configuration for profile settings                        |                        | profiles:<br>&nbsp;&nbsp;.vimrc:<br>&nbsp;&nbsp;&nbsp;&nbsp;- filetype on<br>&nbsp;&nbsp;.bash_aliases:<br>&nbsp;&nbsp;&nbsp;&nbsp;- alias ll='ls -la' |
| POST_BUILD_COMMANDS | no       |         | commands to run after the image build to finish the setup |                        | post_build_commands:<br>&nbsp;&nbsp;- awsume-configure                                                                                                 |

### Build Dockerfile

To create the Dockerfile from Template you have simply to run the following steps.

1. create build.yaml with your needed settings
2. run the script `render.sh`
3. build Docker Image

`render.sh`

The build script will create the `Dockerfile` from template.d with your settings from `build.yaml`.

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

##### run the image with your local user and environment

If you mount your repositories to the DMC you might want to run it with your local user and environment

This should give you a few benefits:

* no permissions issues when editing files from within the container
* being able to use the local ssh auth key for ansible
* local configuration is used in the container (.bashrc, .gitconfig, .vimrc etc)

Example:

```bash
docker run --rm -ti --hostname dmc \
  `# you can include your services environment variables if you like` \
  --env-file ~/service/.docker_env \
  \
  `# run as local user and make the container aware of users + groups` \
  -v /etc/passwd:/etc/passwd:ro \
  -v /etc/group:/etc/group:ro \
  --user "$(id -u):$(id -g)" \
  \
  `# provide ssh socket to the container for ansible to use` \
  -e 'SSH_AUTH_SOCK=/.ssh_auth' \
  -v ${SSH_AUTH_SOCK}:/.ssh_auth \
  \
  `# mount home and use the service subdirectory as workdir` \
  -v ${HOME}:${HOME} \
  -w ${HOME}/service \
  \
  dmc:latest
```

##### mount volumes with docker volume bindfs as root

With the [Docker volume plugin for bindfs](https://github.com/clecherbauer/docker-volume-bindfs), you're able to mount a given path and remap its owner and group.
This way you can be `root` inside the container while still mapping your home-directory inside the container (to `/root`) and using it without permission problems.

```bash
# create the docker volume
docker volume create -d lebokus/bindfs -o sourcePath=$PWD -o map=$(id -u)/0:@$(id -g)/@0 dmcvolume
```

```bash
# run your dmc with the volume
docker run -it --user root -v dmcvolume:/root/ dmc:latest
```

## Migration

With Version 2.0.0 there's a breaking change in the configuration and usage of the DMC.
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
