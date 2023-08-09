# Docker Management Container

The Docker Management Container (or DMC for short) contains a number of plugins and services that are designed to make it easy to create, test, deploy and manage infrastructures. For more information also take a look at our [Blog](https://blog.telekom-mms.com/tech-insights/manage-your-infrastructure-better-with-this-opensource-tool).

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
docker run ghcr.io/telekom-mms/dmc:min

# full
docker run ghcr.io/telekom-mms/dmc:full
```

## Usage

### Setup and Configuration

Setup plugins, services, tools, versions and configuration over file with yaml syntax.

``` bash
touch build.yaml
```

#### Image

The DMC uses the wakemeops image as base image.

##### Image ARG

* `distribution`
  * Required: no
  * Default: `ubuntu`
  * Description: distribution that should be used, see also [wakemeops](https://hub.docker.com/u/wakemeops)
  * Examples:
    * ``` yaml
      distribution: debian
      ```

* `version`
  * Required: no
  * Default: `latest`
  * Description: specific version
  * Examples:
    * ``` yaml
      version: buster
      ```

#### Base

Basic Setup of the DMC.

#### Tools

Tools to be installed within the DMC.

##### Tools ARG

* `packages`
  * Required: no
  * Default:
  * Description: list of packages to be installed
  * Examples:
    * ``` yaml
      packages:
        - ansible
        - docker-ce
        - helm
        - kubectl
      ```

* `repositories`
  * Required: no
  * Default:
  * Description: further repositories that should be used, currently the following are defined with defaults **_[hashicorp, docker, microsoft]_**
  * Examples:

    * ``` yaml
      repositories:
        docker: {}
        microsoft: {}
        hashicorp: {}
      ```

    * ``` yaml
      repositories:
        mongodb:
          gpg: https://www.mongodb.org/static/pgp/server-6.0.asc
          entry: https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse
      ```

* `binaries`
  * Required: no
  * Default:
  * Description: binaries that should be installed, currently the following are supported **_[github, google]_**
  * Examples:

    * ``` yaml
      github:
        - remotemobprogramming/mob=linux_amd64=v3.2.0
        - derailed/k9s=Linux_x86_64
      google:
        - google-cloud-cli
      ```

* `repositories_hashicorp_gpg`
  * Required: no
  * Default: `https://apt.releases.hashicorp.com/gpg`

* `repositories_hashicorp_entry`
  * Required: no
  * Default: `'https://apt.releases.hashicorp.com $(lsb_release -cs) main'`

* `repositories_docker_gpg`
  * Required: no
  * Default: `https://download.docker.com/linux/ubuntu/gpg`

* `repositories_docker_entry`
  * Required: no
  * Default: `'https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'`

* `repositories_microsoft_gpg`
  * Required: no
  * Default: `https://packages.microsoft.com/keys/microsoft.asc`

* `repositories_microsoft_entry`
  * Required: no
  * Default: `'https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main'`

* `binaries_github_uri`
  * Required: no
  * Default: `https://api.github.com/repos`

* `binaries_google_uri`
  * Required: no
  * Default: `https://packages.cloud.google.com/apt/dists/cloud-sdk/main/binary-arm64/Packages`

#### Tool Config

Extension of installed tools.

##### Tool Config ARG

* `requirements`
  * Required: no
  * Default:
  * Description: requirements that should be installed for the used tools, currently the following are supported **_[pip, ansible(roles, collections)]_**
  * Examples:

    * ``` yaml
      requirements:
        pip:
          packages:
            - awsume
          requirements:
            - https://raw.githubusercontent.com/ansible-collections/azure/v1.15.0/requirements-azure.txt
        ansible:
          roles:
            - telekom_mms.grafana
          collections:
            - telekom_mms.acme=2.3.1
            - telekom_mms.icinga_director=1.28.0
          requirements:
            - https://raw.githubusercontent.com/T-Systems-MMS/ansible-role-maxscale/master/requirements.yml
      ```

* `extensions`
  * Required: no
  * Default:
  * Description: extensions that should be installed for the used tools, currently the following are supported **_[az, google, helm]_**
  * Examples:

    * ``` yaml
      extensions:
        az:
          - front-door=1.0.15
        google:
          - gsutil
          - gke-gcloud-auth-plugin
          - kubectl
        helm:
          - https://github.com/databus23/helm-diff=3.5.0
          - https://github.com/jkroepke/helm-secrets
      ```

#### Post Build Config

System configuration and further setups to finish the DMC build.

##### Post Build Config ARG

* `profiles`
  * Required: no
  * Default:
  * Description: configuration for profile settings
  * Examples:

    * ``` yaml
      profiles:
        .vimrc:
          - filetype on
        .bash_aliases:
          - alias ll='ls -la'
      ```

* `post_build_commands`
  * Required: no
  * Default:
  * Description: commands to run after the image build to finish the setup
  * Examples:

    * ``` yaml
      post_build_commands:
        - awsume-configure
      ```

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

## Included renovate preset

We provide a [renovate-preset](https://docs.renovatebot.com/key-concepts/presets/) to include in your configuration.
If you use it renovate can update the versions in your `build.yaml`

Include it like this:

``` json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base",
    "github>T-Systems-MMS/docker-management-container"
  ],
}
```

Change your `build.yaml` like this to use it:

``` yaml
packages:
  # renovate: datasource=repology depName=ubuntu_22_04/ansible versioning=loose
  - ansible=2.10.7+merged+base+2.10.8+dfsg-1

  ansible:
    collections:
      # renovate: datasource=galaxy-collection depName=telekom_mms.acme
      - telekom_mms.acme=2.3.1
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
