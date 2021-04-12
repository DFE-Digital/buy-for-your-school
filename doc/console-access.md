# Console access

We may need a way to access live environments for debugging or incident management purposes in future.

If we do need to open a rails console on production we should pair through the commands we execute to mitigate the risk of data loss.

## Prerequisites

You must have an account that has been invited to the Government Platform as a Service (GPaaS) account. DfE PaaS organisation administrators should be able to invite you if you [request in DfE's #digital-tools-support Slack channel](https://ukgovernmentdfe.slack.com/archives/CMS9V0JQL).

You must have have been given 'Space developer' access to the intended space, for example "sct-prod". Note 'Space manager' is a separate role and does not include all `Space developer` permissions.

[You can sign in to check your account and permissions here](https://admin.london.cloud.service.gov.uk).

## Access

1. From a local terminal login to Cloud Foundry and select the intended space
    ```
    $ cf login -a api.london.cloud.service.gov.uk -u REDACTED@digital.education.gov.uk
    ```
1. See all available spaces
    ```
    $ cf spaces
    ```
1. Change space
    ```
    $ cf space <space name>
    ```
1. View available services
    ```
    $ cf apps
    ```
1. Connect to the environment (in this case production)
    ```
    $ cf ssh <service name>
    ```
1. Navigate to the application
    ```
    $ cd /srv/app
    ```
1. Run the intended commands
    ```
    $ export PATH="$PATH:/usr/local/bin"
    $ /usr/local/bin/ruby bin/rails c
    ```

    or

    ```
    $ /usr/local/bin/ruby bin/rake db:seed
    ```
