# Tools

Tools to be installed within the DMC.

## Tools ARG

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
      awscli:
        - awscli=linux-x86_64=2.0.30
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
