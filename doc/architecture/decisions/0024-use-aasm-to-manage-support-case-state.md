# 24. Use AASM to manage state in Support::Case

Date: 2022-02-22

## Status

Accepted

## Context

```Support::Case``` has a number of states that it can be in and a set of transitions between those states that need to be managed.
AASM has a simple DSL and set of inbuilt methods that will make managing these states and transitions easy

## Consequences

* There is a block at the top of the model detailing all of the states, transitions and events that trigger those transitions.
* Should another model require a state machine, it will be easy to apply one.
* [AASM documentation](https://github.com/aasm/aasm#usage_)
