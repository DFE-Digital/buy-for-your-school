# 21. Use Microsoft Graph API for Email Integration.

  

Date: 2022-01-04

  

## Status

  

![Accepted](https://img.shields.io/badge/adr-accepted-green)

  

## Context

* Procurement Operations team uses a shared mailbox hosted in DfE's Exchange Online to communicate with School Buying Professionals.

* A key requirement from case workers is to record all the email interactions regarding a case in the case management system , so there is a full view of a case and all associated interactions

## Decision

* Use Microsoft Graph for to integrate with Microsoft Exchange Online.

* Use Microsoft Identity [OAuth 2.0 client credentials grant flow](https://github.com/microsoftgraph/microsoft-graph-docs/blob/main/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow) to set up application's permissions for using MS Graph API with restricted permissions only to access shared mailbox.

* Microsoft Graph is recommended by Microsoft and [Outlook API has been deprecated](https://docs.microsoft.com/en-us/previous-versions/office/office-365-api/api/version-2.0/use-outlook-rest-api) 

## Consequences

* There would be increased initial security setup and governance to set up permissions for rails application.