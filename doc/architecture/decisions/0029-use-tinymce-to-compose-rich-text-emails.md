# 29. Use TinyMCE to compose rich-text emails

Date: 2022-05-31

## Status

Accepted

## Context

Integration with Microsoft Graph has enabled users of the case management system to compose emails. The default HTML text box lacks the necessary formatting tools available in a typical email client making it difficult to compose emails. A rich-text editor would mitigate this problem.

## Decision

Add [TinyMCE](https://www.tiny.cloud/) as a dependency.

## Consequences

The rich-text editor allows the user to use the usual formatting tools available in email clients.
