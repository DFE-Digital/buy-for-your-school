# Roles and Portals

Access to portals is dictated by the agents roles. The roles are checked on page load and the agent will be redirected if they do not have sufficient roles required to access (as definied in the policy).

|Portal|Endpoint|Roles required (either)|
|-|-|-|
|Support / ProcOps CMS|`/support`|`internal procops_admin procops`|
|Frameworks Evaluation|`/frameworks`|`framework_evaluator_admin framework_evaluator`|
|Engagement & Outreach|`/engagement`|`internal e_and_o_admin e_and_o`|

- See `app/models/support/agent.rb` for full list of roles.
- See `app/policies/cms_portal_policies.rb` for up to date access policy information.
- Agents with role `global_admin` can access any portal.

## Assigning Roles

Roles can be changed by an agent with sufficiently high enough roles [see permissions](#role-assigning-permissions).

To assign roles, visit any of the following management pages:

|Portal|Role Management URL|
|-|-|
|Support|`/support/management/agents`|
|Engagement|`/engagement/management/agents`|

Developers can modify the roles array on an agent directly using the rails console or database access.

```
$ bundle exec rails c
Running via Spring preloader in process 93412
Loading development environment (Rails 7.0.8)
[1] pry(main)> Support::Agent.find("xxxx").update(roles: ["new", "roles", "here"])
```

### Role assigning permissions

|Role|Can assign...|
|-|-|
|Global Admin|Any role|
|Proc-Ops Admin|Proc-Ops staff|
|E & O Admin|E & O staff|
|Framework Evaluator Admin|Framework Evaluator staff|

Any roles not listed cannot grant roles at all.
