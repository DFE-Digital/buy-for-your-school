# 13. use-dfe-sign-in-as-auth-provider

Date: 2021-03-22

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

The service needs a way to authenticate trusted school buying professionals and to restrict the majority of access to the public.

We believe a simpler password-less authentication mechanism would be all that's required. This service does not need any of the school and user information held within DfE Sign-in (DSI). DfE governance has reviewed our concern and decided this service should use DSI.

There is currently no formal recommendation for a tool of choice in the technical guidance https://github.com/DFE-Digital/technical-guidance.

We want a tool that provides an open and modern security standard.

## Decision

We are going to use DSI as our single sign-on provider using the OIDC standard.

## Consequences

- we think that the additional steps needed for the sign in journey will negatively affect the user experience and the ability for users to succeed first time
- we think it will be difficult to clearly steer users who don't have a DSI account to create one first before continuing back (this will be a dead end for our service until they talk to their school approver)
- the DSI has been in service for a couple of years now. We expect that most of our users will already have accounts on sign-in
- DSI is being used actively by other DfE Digital services such as Claim, Apply and Teaching Vacancies. It is a core part of the DfE's service wide design and infrastructure that should be actively supported
- in future the service may need more information that DSI can make available such as school information, using DSI already would make this easier to obtain
- there may be advantages to the user experience for school users who use other DfE digital services. Using DSI would present a single view that may increase trust and allow them to jump between services without repeat sign ins
