# 30. Use Knapsack to run tests in parallel

Date: 2022-08-04

## Status

Accepted

## Context

Our test suite can take upwards of 10 minutes to complete as tests are executed synchronously. Significant time savings can be achieved by parallelising this process in the CI pipeline.

## Decision

Add the [Kanpsack](https://github.com/KnapsackPro/knapsack) gem as a development and test dependency and update the CI pipeline accordingly.

## Consequences

The test suite can now complete faster as tests are split into smaller chunks across a number of CI nodes.
