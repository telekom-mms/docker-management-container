# Docker Management Container

The Docker Management Container (or DMC for short) contains a number of plugins and services that are designed to make it easy to create, test, deploy and manage infrastructures. For more information also take a look at our [Blog](https://blog.telekom-mms.com/tech-insights/manage-your-infrastructure-better-with-this-opensource-tool).

<picture>
  <source
    srcset="https://user-images.githubusercontent.com/3198961/186105564-3901aded-21f1-4191-b323-e943f49ea5ed.png"
    media="(prefers-color-scheme: dark)"
    width="30%" height="30%">
  <img width="30%" height="30%" src="">
</picture>

## How does the DMC work?

The DMC provides a Dockerfile template (from modular setup) that creates the Dockerfile with the desired tools and versions through a file and script. This Dockerfile is then used for the actual build of the container. The Dockerfile itself does not need to be kept, but is created and discarded after the build of the Dockerfile.

The DMC uses the wakemeops as base setup, for more information about wakemeops look at the [docs](https://docs.wakemeops.com/).

### Try it out

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

Create a build.yaml:

``` bash
touch build.yaml
```

Then fill it with the settings you need:

* [Image](docs/usage/setup_and_configuration/image.md)
* [Base](docs/usage/setup_and_configuration/base.md)
* [Tools](docs/usage/setup_and_configuration/tools.md)
* [Tool Config](docs/usage/setup_and_configuration/tool_config.md)
* [Post Build Config](docs/usage/setup_and_configuration/post_build_config.md)
* [Tool Config](docs/usage/setup_and_configuration/tool_config.md)

Take a look at the examples to see what's possible:

## Examples

Examples for the `build.yaml` could be found under [examples](examples):

* [minimal](examples/min_build.yaml)
* [full](examples/full_build.yaml)

### Build

#### Dockerfile

To create the Dockerfile from Template you have to run the following steps.

1. Create `build.yaml` with your needed settings
2. Run the script `render.sh`
3. Build the Docker Image

`render.sh`

The build script will create the `Dockerfile` from template.d with your settings from `build.yaml`.

``` bash
sh render.sh .
```

#### Image

``` bash
docker image build -t dmc:latest .
```

Examples for build within CI Pipelines can be found under [examples/pipeline](examples/pipeline).

#### Included build preset

Provided build presets can be found under [pipeline](pipeline). The preset also sets some labels e.g. the version of the dmc release (dmc-version), you can get this information with `docker inspect`.

``` bash
> docker inspect service-mgmt-dmc --format '{{ json .Config.Labels }}' | jq .
{
  "dmc-version": "3.2.0",
  "org.wakemeops.base_image": "\"docker.io/ubuntu:latest\"",
  "org.wakemeops.commit": "\"65d81642eb025d20c4db5b45758879b379bc6aa1\"",
  "org.wakemeops.maintainers": "\"WakeMeOps <wakemeops.com>\""
}
```

* [gitlab-ci](docs/build/image/preset/gitlab-ci.md)

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
    "github>telekom-mms/docker-management-container"
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

## Others

Feedback, suggestions for improvement and expansion, and of course collaboration are expressly desired.
