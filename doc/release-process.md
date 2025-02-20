# Release process

- [Production](#production)
- [Staging](#staging)
- [Development](#development)

## Production

### 1. Check what will be released

To do this, get the diff between `main` and `production` branches. [Compare
here](https://github.com/DFE-Digital/buy-for-your-school/compare/production...main).

### 2. Start the deployment process

Production deployment is automated with github actions, but you will need to
update the `production` branch for it to deploy changes.

Switch to the `production` branch, ensure it is updated from origin, then
rebase it with `origin/main`.

```
$ git fetch
$ git checkout production
$ git reset --hard origin/production
$ git rebase origin/main
$ git push --force-with-lease
```

NOTE: `git push --force-with-lease` is important, the force push will be
rejected if changes have been made in origin that differ from your local branch.

Monitor the [github actions
page](https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/ci-full-pipeline.yml)
to check status of the automated deployment.

After a successful deployment, you will need to update the release log
[here](https://dfedigital.atlassian.net/wiki/spaces/GHBFS/pages/3535732763/Development+Release+log).
To get the docker image, find the latest version with the tag `production` on
[the container registry
page](https://github.com/DFE-Digital/buy-for-your-school/pkgs/container/buy-for-your-school).

In certain circumstances, you might see multiple images listed. In this case,
you can find the correct one by looking in Azure under _Home → Container Apps →
prodghbs-buyforyourschool → Containers → Properties → Image and tag_.

## Staging

Staging is automatically deployed with changes appear in `main`.

Monitor the [github actions
page](https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/ci-full-pipeline.yml)
to check status of the automated deployment.

## Development

Development deployment is automated with github actions, but you will need to
update the `development` branch for it to deploy changes.

Switch to the `development` branch, ensure it is updated from origin, then
rebase it with `main`.

```
$ git fetch
$ git checkout development
$ git reset --hard origin/development
$ git rebase your-feature-branch
$ git push --force-with-lease
```

NOTE: `git push --force-with-lease` is important, the force push will be
rejected if changes have been made in origin that differ from your local branch.
This ensures you don't overwrite other developer's changes on development.

If you need to make repeated changes, always reset `development` and then
rebase your feature branch again.

Monitor the [github actions
page](https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/ci-full-pipeline.yml)
to check status of the automated deployment.
