# 28. Use ClamAV to scan email attachments

Date: 2022-05-31

## Status

Accepted

## Context

Integration with Microsoft Graph has enabled users of the case management system to compose emails and add attachments. Attachments can be unsafe and should be scanned before sending.

## Decision

Use [ClamAV](https://www.clamav.net/), an open-source antivirus engine to scan email attachments. The [ClamAV Docker image](https://hub.docker.com/r/niilo/clamav-rest/) is deployed on GOV.UK PaaS as an application and is accessed via its REST API. The virus database is updated automatically.

## Consequences

Email attachments are now scanned for viruses before an email is sent out.
