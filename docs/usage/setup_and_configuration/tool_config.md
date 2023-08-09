# Tool Config

Extension of installed tools.

## Tool Config ARG

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
