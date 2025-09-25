# Feature Flags
Feature flags were introduced to enable functionality to be enabled / disabled within the live environment.

These allowed for:
- Functionality to be tested  / enabled for a set period of time in live to assess impact
- Large pieces of functionality to be developed without ‘blocking’ the release pipeline and to discourage a developer from having large chunks of code that is not merged into the main code base
- Multiple developers to work together on a large piece of new functionality 

On the whole, the use of feature flags is transitional and they should be removed once the need for them has gone.

## Flipper gem
We use the flipper gem to implement feature flags. Documentation on how to use flipper can be found [here](https://www.flippercloud.io/docs/introduction).

To add a feature flag in the code, you can use a conditional and wrap bits of code you want to show within it. When choosing a name, make sure it is descriptive enough to understand what the flag is for, but not so long that it becomes hard to read or type. It should also use snake case to follow convention. A simple example is shown below:
```
if Flipper.enabled?(:my_feature)
  # do the thing
else
  # do the other thing
end
``` 

## Enabling / Disabling feature flags
Visit https://`<your-environment>`/flipper e.g. https://www.get-help-buying-for-schools.service.gov.uk/flipper and enter the username and password for feature flag access.

The username and password for each environment can be found in Azure within each container app (e.g., `devghbs-buyforyourschool`) in the secrets section of settings on the left hand side.

Click on `add feature` and enter the name you have used for your feature flag. You can then choose to enable and disable it based on need. It's important to remember you will need to add and enable/disable on each environment you use, including local host. 

## Current Flags
|Flag name|Description|Status|Actions|
|--|--|--|--|
|auto_send_siteAdditions_gas|when enabled, auto email sending to supplier (Total) with site addition and portal access forms|
|auto_send_siteAdditions_power|when enabled, auto email sending to supplier (EDF) with site addition and portal access forms|
|customer_satisfaction_survey|Replace the exit survey with the new customer satisfaction survey.|ENABLED|Feature now live, flag to be removed|
|energy|Energy for Schools|ENABLED|Feature now live, flag to be removed|
|maintenance_mode|Prevent user access to the application. Intended for infrastructure or data maintenance.|DISABLED|To be enabled when required|
|rfh_usability_survey|Embed the RfH usability survey in the RfH submission confirmation page.|ENABLED|Feature now live, flag to be removed|
|sc_tasklist_case|The task list tab for a case at level 4 or 5 will be visible, and the 'case action_required' flag will be updated based on the evaluation document upload status and the evaluation approval status. |ENABLED in development, DISABLED in production|To be enabled when all components of the task list are ready|
|usability_surveys|Usability survey for FABS|ENABLED|Feature now live, flag to be removed|


When the feature flag is no longer needed, you can remove it from the code and from the flipper features area in all the environments where it was created. It should also be removed from the current flags table above so we have an up-to-date record of feature flags in the system.
