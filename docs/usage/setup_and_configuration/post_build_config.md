# Post Build Config

System configuration and further setups to finish the DMC build.

## Post Build Config ARG

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
