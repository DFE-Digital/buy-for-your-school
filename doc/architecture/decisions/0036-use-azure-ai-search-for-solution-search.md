# 36. Use Azure AI Search for solution search

Date: 2026-07-15

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

The application currently uses Elasticsearch/OpenSearch-style search for solutions, with the infrastructure historically backed by the Bonsai add-on on Heroku.

That approach works for keyword search, but it keeps the application tied to a separate search service and to legacy Heroku infrastructure. It also limits future improvements in search relevance and discovery.

We want solution search to align more closely with the application's Azure hosting. We also want a search platform that can grow into richer retrieval approaches, including embeddings, vector search, and semantic ranking. Those features are not practical to introduce with the current Elasticsearch approach in this project.

Category search is not part of this change and continues to use the Contentful API directly.

## Decision

Use Azure AI Search as the search backend for solutions.

The Azure implementation will replace the existing Elasticsearch/OpenSearch solution search path while keeping category search on Contentful.

This decision allows us to:

- retire the dependency on the Heroku Bonsai add-on;
- keep the search infrastructure aligned with the rest of the Azure-hosted application;
- create a path to improve search relevance with Azure AI Search features such as embeddings, vector search, and semantic ranking;
- keep the current solution indexing and querying logic under application control rather than depending on the older search stack.

## Consequences

### Positive

- Removes the dependency on Bonsai/Heroku for solution search
- Aligns solution search with Azure hosting
- Creates a path to richer AI-assisted search features later
- Keeps category search unchanged and low risk

### Risks / Considerations

- Azure AI Search still needs explicit indexing and maintenance within the application
- Search relevance will need to be validated against the existing solution search behaviour
- If the Azure service is unavailable, solution search will need a clear fallback or operational response
- The existing Elasticsearch/OpenSearch path should remain available during migration and comparison until Azure search is proven
