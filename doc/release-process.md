# Release process

To create a new release and deploy it to production, follow this process:

## 1. Create the release pull request

1. Make a branch from `develop` called `release-xxx` (where `xxx` is the sequential release number)
1. Move all features from the `Unreleased` section of [`CHANGELOG.md`](../CHANGELOG.md) to a new heading with the release number linked to a diff of the two latest versions, together with the date in the following format:

  ```markdown
  ## [Release XXX] - 2020-10-27

  ...

  [release xxx]:
    https://github.com/DFE-Digital/buy-for-your-school/compare/previous-release...release-xxx
  ```

1. Create a commit for the release, including the changes for the release in the commit message
1. Push the branch
1. Open a pull request to merge the new branch to `develop` and get it reviewed

## 2. Confirm the release and review the pull request

The pull request should be reviewed to confirm that the changes currently are safe to ship and that [`CHANGELOG.md`](../CHANGELOG.md) accurately reflects the changes included in the release:

1. Confirm the release with any relevant people (for example the product owner)
1. Think about any dependencies that also need considering: dependent parts of the service that also need updating; environment variables that need changing/adding; third-party services that need to be set up/updated
1. Merge the pull request with `develop`
1. Merge the resultant merge commit into `main`

## 3. Push the tag

Once the pull request has been merged, create a tag against the `main` branch commit in the format `release-xxx` (zero-padded again) and push it to GitHub:

```sh
git tag release-xxx merge-commit-for-release
git push origin refs/tags/release-xxx
```

## 4. Validate the deployment

Check in the production environment to make sure the deployment has gone as expected, and that no problems have arisen during build or release stages.

## 5. Update Trello

Features in the "Approved" column should be moved to "Done".

## 6. Announce the release in Slack

Let everybody know that a new release has been shipped.

The usual place to do this is #sct-buy-for-your-school, with a message like:

> 🚢 Release ### for Buy for your school is now live. Changes in this release: [link to changelog] 🚀
