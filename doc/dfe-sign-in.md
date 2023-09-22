# DfE Sign-In

**_DfE Sign-In_** `DSI` is the **_Single Sign-On_** `SSO` provider for this service.

## Environments

There are three different DfE sign in environments, an account on one environment will not be shared across to the other environments. However, both staging and development environments both use the same DfE sign in environment so the account can be shared in effect.

Below is a mapping of which applications are backed by which DfE sign in environments:

| App Environment |DSI Env              | DSI service management    | Request Organisations |
| :------------- |:------------------- | :------------------------- | --------------------- |
| Local Dev      |[test][test]         | [manage][test-manage]      | [test][test-request-org] |
| Development    |[pre-prod][pre-prod] | [manage][pre-prod-manage]  | [pre-prod][pre-prod-request-org] |
| Staging        |[pre-prod][pre-prod] | [manage][pre-prod-manage]  | [pre-prod][pre-prod-request-org] |
| Production     |[prod][prod]         | [manage][prod-manage]      | [prod][prod-request-org] |

## Getting an account
### Sign up

DfE Sign in is "self service" so in order to get an account you need to sign up yourself. Please click on each link in the "DSI Env" in the table above and follow the steps to create an account.

### Request access

Now you have an account you will be able to log in, but the application does further authorization with your account details.

In order to gain access to parts of the system you need to request access to the "DfE Commercial Procurement Operations" organisation. Use the links in the "Request Organisations" column of the table above, search for "DfE Commercial Procurement Operations" organisation and then request access.

---

[pre-prod]: https://pp-services.signin.education.gov.uk
[pre-prod-register]: https://pp-profile.signin.education.gov.uk/register
[pre-prod-manage]: https://pp-manage.signin.education.gov.uk/services/00487750-C9B8-414C-8746-1076885456E0/service-configuration
[pre-prod-api]: https://pp-api.signin.education.gov.uk
[pre-prod-request-org]: https://pp-services.signin.education.gov.uk/request-organisation/search
[prod]: https://services.signin.education.gov.uk
[prod-register]: https://profile.signin.education.gov.uk/register
[prod-manage]: https://manage.signin.education.gov.uk/services/9D1B3879-3495-4D3F-AB7A-ED9B8E968EFF/service-configuration
[prod-api]: https://api.signin.education.gov.uk
[prod-request-org]: https://services.signin.education.gov.uk/request-organisation/search
[test]: https://test-services.signin.education.gov.uk
[test-register]: https://test-profile.signin.education.gov.uk/register
[test-manage]: https://test-manage.signin.education.gov.uk/services/FD39DCFC-9B60-46C4-ACDC-699A2468B46F/service-configuration
[test-api]: https://test-api.signin.education.gov.uk
[test-users]: https://test-services.signin.education.gov.uk/approvals/users
[test-school]: https://test-services.signin.education.gov.uk/approvals/50F4A834-9314-4A66-969E-C86D03821C26/users
[test-request-org]: https://test-services.signin.education.gov.uk/request-organisation/search
[digi-tools]: https://ukgovernmentdfe.slack.com/archives/CMS9V0JQL
[dfe_sign-in]: https://ukgovernmentdfe.slack.com/archives/C5S500XB6



