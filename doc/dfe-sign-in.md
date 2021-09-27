# DfE Sign-In

**_DfE Sign-In_** `DSI` is the **_Single Sign-On_** `SSO` provider for this service.

There are [testing][test-register], [pre-production][pre-prod-register] and [production][prod-register] environments for DSI that each require registration.

## Registration

- A person with "approver" privileges for at least one school needs to invite you.
- [This school][test-school] has been used in the `test` DSI environment.
- Contact DfE [#digital-tools-support][digi-tools] and [#dfe_sign-in][dfe_sign-in] Slack channels for further assistance.

## Access

The DSI API returns a user's affiliated organisations with their type name and number.
Will restrict access to users from certain types of establishment.

**Accept**

    1   Community School
    2   Voluntary Aided School
    3   Voluntary Controlled School
    5   Foundation School
    6   City Technology College
    7   Community Special School
    12  Foundation Special School
    14  Pupil Referral Unit
    28  Academy Sponsor Led
    33  Academy Special Sponsor Led
    34  Academy Converter
    35  Free Schools
    36  Free Schools Special
    38  Free Schools - Alternative Provision
    40  University Technical College
    41  Studio Schools
    42  Academy Alternative Provision Converter
    43  Academy Alternative Provision Sponsor Led
    44  Academy Special Converter

**Reject**

    8   Non-Maintained Special School
    10  Other Independent Special School
    11  Other Independent School
    15  LA Nursery School
    18  Further Education
    24  Secure Units
    25  Offshore Schools
    26  Service Children's Education
    27  Miscellaneous
    29  Higher Education Institution
    30  Welsh Establishment
    31  Sixth Form Centres
    32  Special Post 16 Institution
    37  British Overseas Schools
    39  Free Schools - 16-19
    45  Academy 16-19 Converter
    46  Academy 16-19 Sponsor Led
    47  Children's Centre
    48  Children's Centre Linked Site
    56  Institution funded by other government department


## Environments

This service has numerous environments and each needs to be paired and configured with a unique DfE environment.

|             | Enabled  |       DSI Env        |  DSI service management   |
| :---------- | :------: | :------------------: | :-----------------------: |
| Development | optional |     [test][test]     |   [manage][test-manage]   |
| Test        | optional |     [test][test]     |   [manage][test-manage]   |
| Staging     |   true   | [pre-prod][pre-prod] | [manage][pre-prod-manage] |
| Research    |   true   | [pre-prod][pre-prod] | [manage][pre-prod-manage] |
| Production  |   true   |     [prod][prod]     |   [manage][prod-manage]   |

DSI DNS Aliases:

- `https://interactions.signin.education.gov.uk` -> `https://services.signin.education.gov.uk`
- `https://pp-interactions.signin.education.gov.uk` -> `https://pp-services.signin.education.gov.uk`
- `https://test-interactions.signin.education.gov.uk` -> `https://test-services.signin.education.gov.uk`

## Development

In development, setting the environment variable `DFE_SIGN_IN_ENABLED` to false will bypass DSI.
You can provide _any_ value in the `UID` field to sign in.

Communicating with DSI in development requires a secure connection.

Create a self-signed certificate:

`$ openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout localhost.key -out localhost.crt`

Firefox will permit the use of this certificate. On OSX, Chrome will require that certificate be trusted.
In **Keychain Access** add it to the **Certificates** in the **System Keychain**.
Use `File > Import Items` and import `localhost.crt`.
Once imported change the trust level to `Always Trust`.

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
[digi-tools]: https://ukgovernmentdfe.slack.com/archives/CMS9V0JQL
[dfe_sign-in]: https://ukgovernmentdfe.slack.com/archives/C5S500XB6
[test-school]: https://test-services.signin.education.gov.uk/approvals/50F4A834-9314-4A66-969E-C86D03821C26/users





