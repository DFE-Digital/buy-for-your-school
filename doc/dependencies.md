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
