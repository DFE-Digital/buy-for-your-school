# Logging

## Logit

Logs for all live environments are aggregated in the [Logit serivce](https://dashboard.logit.io).

An existing developer should be able to invite you.

Environment variables are used to tell the infrastructure which log stream URL to send logs to. These can be changed in GitHub Secrets within the repository:

```
PROD_TF_VAR_SYSLOG_DRAIN_URL=
STAGING_TF_VAR_SYSLOG_DRAIN_URL=
PREVIEW_TF_VAR_SYSLOG_DRAIN_URL=
RESEARCH_TF_VAR_SYSLOG_DRAIN_URL=
```

For help putting together the drain URL, there is a [service-specific guide in
the CloudFoundry
documentation](https://docs.cloudfoundry.org/devguide/services/log-management-thirdparty-svc.html)
which includes LogIt. We use the TCP-SSL port with the `syslog-tls://` URL
scheme.

Remember to deploy the application again to propagate environment variable changes.

## GPaaS

If Logit isn't working you can ask GPaaS to view the logs for individual apps using the Cloud Foundry CLI.

Log in:
```
$ cf login -a api.london.cloud.service.gov.uk -u REDACTED@digital.education.gov.uk
```

Select the intended space:
```
$ cf spaces
$ cf target -s sct-staging
```

Find the app name for the process you want to see logs for:
```
$ cf apps
```

Ask for the logs:
```
$ cf logs buy-for-your-school-research
```
