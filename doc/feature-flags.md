# Feature Flags

Feature flags were introduced to enable functionality to be enabled / disabled within the live environment.

These allowed for:
- Functionality to be tested  / enabled for a set period of time in live to assess impact
- Large pieces of functionality to be developed without ‘blocking’ the release pipeline and to discourage a developer from having large chunks of code that is not merged into the main code base
- Multiple developers to work together on a large piece of new functionality 

On the whole, the use of feature flags is transitional and they should be removed once the need for them has gone.

## Current Flags
|Flag name|Description|Status|Actions|
|--|--|--|--|
|rfh_usability_survey|When enabled, embeds the RfH usability survey in the RfH submission confirmation page.|ENABLED|Feature now live, flag to be removed|
|customer_satisfaction_survey|When enabled, replaces the existing exit survey with the new customer satisfaction survey.|ENABLED|Feature now live, flag to be removed|
|maintenance_mode|Special flag, when enabled will prevent user access to the application. Intended for infrastructure or data maintenance.|DISABLED|To be enabled when required|
|sc_tasklist_tab|When enabled, the task list tab for a case at level 4 or 5 is visible.|ENABLED in development, DISABLED in production|To be enabled when all components of the task list are ready|

## Enabling Disabling feature flags
Visit https://`<your-environment>`/flipper e.g. https://www.get-help-buying-for-schools.service.gov.uk/flipper and enter the username and password for feature flag access.

The username and password for each environment can be found in Azure within each container app (e.g., `devghbs-buyforyourschool`) in the secrets section of settings on the left hand side.