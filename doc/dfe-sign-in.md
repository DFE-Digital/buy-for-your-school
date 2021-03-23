# DfE Sign-in

We are using DfE Sign-in as the Single Sign-on provider for this service.

## Onboarding

For development, with `DFE_SIGN_IN_ENABLED` set to false you do not need the following in order to start the app. You can provide _any_ value in the `UID` field to sign in.

If you'd like to sign in on a live environment:

1. DfE need to invite your DfE email address to the [necessary environments](#environments) that you can sign in as a regular user. We asked in [the DfE #digital-tools-support Slack channel](https://ukgovernmentdfe.slack.com/archives/CMS9V0JQL)
2. Another DfE user that is an approver for at least one school needs to invite you. This could an existing dev on the team. [We have been using this school for staging access](https://test-services.signin.education.gov.uk/approvals/50F4A834-9314-4A66-969E-C86D03821C26/users)
3. You should now be able to sign into the service's staging environment from this application's sign in journey

## Environments

This service has numerous environments and each needs to be paired and configured with a unique DfE environment.

|                | Enabled      | DfE Sign-in Env                                                       | DfE manage service |
| :------------- | :----------: | :-------------------------------------------------------------------: | :----------------: |
|  Development   |  false       |                                                                       |                    |
|  Staging       |  true        | [test-integration](https://test-interactions.signin.education.gov.uk) | [manage](https://test-manage.signin.education.gov.uk/services/FD39DCFC-9B60-46C4-ACDC-699A2468B46F/service-configuration)
|  Research      |  false       |                                                                       |                    |
|  Preview       |  false       |                                                                       |                    |
|  Production    |  false       |                                                                       |                    |
