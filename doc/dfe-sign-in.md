# DfE Sign-In

**_DfE Sign-In_** `DSI` is the **_Single Sign-On_** `SSO` provider for this service.

There are [testing][test-register], [pre-production][pre-prod-register] and [production][prod-register] environments for DSI that each require registration.

## Registration

Anyone can register for a DSI profile in each environment.
An *approver* at a supported establishment can invite users to their organisation.
[This school][test-school] has been used for testing access for local development.
Contact DfE [#digital-tools-support][digi-tools] and [#dfe_sign-in][dfe_sign-in] Slack channels for further assistance.

## Environments

This service has deployment environments and each is paired with a corresponding DSI environment.

|                | Enabled      | DSI Env              | DSI service management     |
| :------------- | :----------- | :------------------- | :------------------------- |
| Development    | optional     | [test][test]         | [manage][test-manage]      |
| Staging        | true         | [pre-prod][pre-prod] | [manage][pre-prod-manage]  |
| Research       | true         | [pre-prod][pre-prod] | [manage][pre-prod-manage]  |
| Production     | true         | [prod][prod]         | [manage][prod-manage]      |

DSI DNS Aliases:

- `https://interactions.signin.education.gov.uk` -> `https://services.signin.education.gov.uk`
- `https://pp-interactions.signin.education.gov.uk` -> `https://pp-services.signin.education.gov.uk`
- `https://test-interactions.signin.education.gov.uk` -> `https://test-services.signin.education.gov.uk`

## Development

In development, setting the environment variable `DFE_SIGN_IN_ENABLED` to false will bypass DSI.
You can provide _any_ value in the `UID` field to sign in.
The application has matured and now requires user data provided by DSI therefore bypassing has limited use.

Communicating with DSI in development requires a secure connection.

Create a self-signed certificate:

`$ openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout localhost.key -out localhost.crt`

Firefox will permit the use of this certificate. On OSX, Chrome will require that certificate be trusted.
In **Keychain Access** add it to the **Certificates** in the **System Keychain**.
Use `File > Import Items` and import `localhost.crt`.
Once imported change the trust level to `Always Trust`.

## Organisations

The service leverages a user's affiliation to an organisation within DSI to control access.
The development team should use the `test` DSI environment variables in `.env.development.local`.
Developers in the test environment can [*approve* or *invite*][test-users] new team members.
The organisation **"DfE Commercial Procurement Operations"** is required to gain access beyond `/support` in each environment.
The lead developer or product manager will be approvers and can invite new team members thereby granting access to live environments.

---

[pre-prod]: https://pp-services.signin.education.gov.uk
[pre-prod-register]: https://pp-profile.signin.education.gov.uk/register
[pre-prod-manage]: https://pp-manage.signin.education.gov.uk/services/00487750-C9B8-414C-8746-1076885456E0/service-configuration
[pre-prod-api]: https://pp-api.signin.education.gov.uk
[prod]: https://services.signin.education.gov.uk
[prod-register]: https://profile.signin.education.gov.uk/register
[prod-manage]: https://manage.signin.education.gov.uk/services/9D1B3879-3495-4D3F-AB7A-ED9B8E968EFF/service-configuration
[prod-api]: https://api.signin.education.gov.uk
[test]: https://test-services.signin.education.gov.uk
[test-register]: https://test-profile.signin.education.gov.uk/register
[test-manage]: https://test-manage.signin.education.gov.uk/services/FD39DCFC-9B60-46C4-ACDC-699A2468B46F/service-configuration
[test-api]: https://test-api.signin.education.gov.uk
[test-users]: https://test-services.signin.education.gov.uk/approvals/users
[test-school]: https://test-services.signin.education.gov.uk/approvals/50F4A834-9314-4A66-969E-C86D03821C26/users
[digi-tools]: https://ukgovernmentdfe.slack.com/archives/CMS9V0JQL
[dfe_sign-in]: https://ukgovernmentdfe.slack.com/archives/C5S500XB6

