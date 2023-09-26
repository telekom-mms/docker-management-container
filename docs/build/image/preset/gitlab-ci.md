# [gitlab-ci](pipeline/gitlab-ci.yml)

## Inputs

| variable | description | default |
| --- | --- | --- |
| GITHUB_DMC_TAG | version of the dmc release | latest version |
| DMC_NAME | name of the container | dmc |
| DMC_IMAGE | full image name  | `$CI_REGISTRY_IMAGE/${DMC_NAME}` |

The preset needs a `.docker-login`-extend. In it you have to define your docker registry information.
To include the preset see [gitlab-ci](/examples/pipeline/gitlab-ci.yml)
