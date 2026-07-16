# 37. Remove VCR gem and cassette fixtures

Date: 2026-07-15

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

The test suite previously used the `vcr` gem for a small set of FABS specs that exercised Contentful-backed pages and models.

This had a few downsides:

- the test behaviour depended on recorded HTTP interactions rather than the explicit inputs the code actually needs;
- cassette fixtures made the test suite harder to understand and maintain because the important data was hidden in YAML recordings;
- tests could become brittle when the underlying Contentful payload shape changed, even if the application logic did not;
- the cassette files added a large amount of test fixture noise to the repository;
- VCR pulled in extra test infrastructure for a narrow use case that could be covered more directly with stubs and local doubles.

For these specs, the application only needed a deterministic way to provide Contentful-like records to the models and request/feature tests. That can be done more clearly with explicit test doubles and direct stubs.

## Decision

Remove the `vcr` gem, its support setup, and the recorded cassette fixtures from the repository.

Replace the affected specs with explicit stubs and local doubles that provide the Contentful data they need directly.

## Consequences

### Positive

- Tests become clearer because each spec now shows its own dependencies directly
- The suite is less brittle because it no longer depends on recorded HTTP traffic
- The repository contains fewer generated fixture files
- There is less test infrastructure to maintain
- Spec failures point at the application behaviour under test rather than at stale cassette data
- The test approach aligns better with the general best practice of stubbing external service boundaries in unit and request specs

### Risks / Considerations

- Some tests now rely more heavily on hand-built doubles, so those doubles need to stay close to the real Contentful shapes the application expects
- If the application starts needing broader integration coverage against Contentful again, a different strategy would need to be introduced intentionally rather than relying on VCR by default
