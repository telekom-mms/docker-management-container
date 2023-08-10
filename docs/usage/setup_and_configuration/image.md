# Image

The DMC uses the wakemeops image as base image.

## Image ARG

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
