# Dependencies

## Reviewing Ruby gem vulnerabilities

Use `bundle-audit` to check the current `Gemfile.lock` against the public Ruby advisory database.

Refresh the advisory database before running a check:

```bash
bundle exec bundle-audit update
```

Run the vulnerability check from the repository root:

```bash
bundle exec bundle-audit check
```

If you only want to see issues that are not ignored in a local config, use the same command with your normal project setup.

This is useful when:

- reviewing whether a branch has cleared known Ruby vulnerabilities before merge
- checking the current lockfile without waiting for Dependabot PRs
- confirming which vulnerable gems still remain after a targeted update

`bundle-audit` only reports Ruby gem issues. For JavaScript dependencies, use the appropriate Node tooling separately.

## Reviewing JavaScript package vulnerabilities

Use the built-in Yarn audit command to check the current `yarn.lock` for known JavaScript package vulnerabilities.

Run the audit from the repository root:

```bash
yarn audit
```

If you need to trace a deprecation warning emitted during the audit, run:

```bash
NODE_OPTIONS=--trace-deprecation yarn audit
```

This is useful when:

- reviewing whether a branch has cleared known Node package vulnerabilities before merge
- checking the current lockfile without waiting for Dependabot PRs
- confirming that conservative `package.json` or `resolutions` changes have removed the reported issues

Notes:

- a clean result is `0 vulnerabilities found`
- Yarn 1 may still print dependency or deprecation warnings even when the audit is clean
- resolution warnings should be interpreted carefully: they often mean Yarn is applying an override to a transitive dependency, not that the vulnerable version is still installed
