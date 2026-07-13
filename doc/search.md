# Solution search

Buying solution search can use one of three backends:

- Contentful API search
- OpenSearch, for the existing Elasticsearch-style solution search
- Azure AI Search, as the replacement path for solution search only

Category search still uses the Contentful API directly and is not indexed in either OpenSearch or Azure AI Search.

## Choosing the backend

The current selection order is:

1. If `azure_ai_search` is enabled, solution search uses Azure AI Search.
2. Else if `USE_OPENSEARCH` is set to `true`, solution search uses OpenSearch.
3. Otherwise solution search falls back to the Contentful API.

The `azure_ai_search` feature flag is documented in [feature-flags.md](feature-flags.md). It should be enabled when you want to switch solution search to Azure AI Search for development, staging, or rollout testing.

## Azure AI Search

Azure AI Search is the preferred replacement for solution search.

It currently covers **solutions only**. Categories remain on the Contentful API.

### Environment variables

Azure AI Search uses:

- `AZURE_AI_SEARCH_ENDPOINT`
- `AZURE_AI_SEARCH_API_KEY`
- `AZURE_AI_SEARCH_INDEX_NAME`
- `AZURE_AI_SEARCH_QUERY_TYPE`
- `AZURE_AI_SEARCH_TOP`
- `AZURE_AI_SEARCH_SEMANTIC_CONFIGURATION`

Typical local or staging values are:

```sh
AZURE_AI_SEARCH_ENDPOINT=https://<your-search-service>.search.windows.net
AZURE_AI_SEARCH_API_KEY=<your-api-key>
AZURE_AI_SEARCH_INDEX_NAME=solution-data
AZURE_AI_SEARCH_QUERY_TYPE=simple
AZURE_AI_SEARCH_TOP=10
```

If semantic search is enabled on the Azure service, `AZURE_AI_SEARCH_QUERY_TYPE` can be set to `semantic`.
If `AZURE_AI_SEARCH_SEMANTIC_CONFIGURATION` is omitted, the application uses the default semantic configuration name defined in code.

### Indexing solutions

Azure solution search is populated by:

```sh
bundle exec rake azure_search:create_index
bundle exec rake azure_search:index
```

The index task:

- creates or uses the Azure AI Search index
- fetches solutions from Contentful
- bulk indexes each solution into Azure AI Search

The Azure index currently stores the same core solution fields used for search:

- id
- title
- description
- summary
- slug
- provider reference
- primary category

There is also a maintenance task to clear the index:

```sh
bundle exec rake azure_search:clear
```

And a task to delete the index entirely:

```sh
bundle exec rake azure_search:delete_index
```

## OpenSearch

OpenSearch-backed solution search is enabled when:

- `USE_OPENSEARCH` is set to `true`
- either `OPENSEARCH_URL` or `BONSAI_URL` points to an OpenSearch instance

The search client reads the OpenSearch URL from:

```ruby
ENV["OPENSEARCH_URL"] || ENV["BONSAI_URL"]
```

### Indexing solutions

The OpenSearch index is populated by:

```sh
bundle exec rake search:index
```

The task:

- creates the `solution-data` index if it does not already exist
- fetches solutions from Contentful
- bulk indexes each solution into OpenSearch

### Local development

To use OpenSearch locally:

1. Set `USE_OPENSEARCH=true`.
2. Set `OPENSEARCH_URL` or `BONSAI_URL` to a local or remote OpenSearch instance.
3. Run `bundle exec rake search:index` to create and populate the index.

After indexing, solution searches will query OpenSearch instead of Contentful.

### Bonsai

FABS historically used the Bonsai service running on Heroku for search. The migrated solution search still supports that service for now through `BONSAI_URL`.

This is temporary. Once Azure AI Search is fully adopted, `BONSAI_URL` can be removed.

## Local development

To use Azure AI Search locally:

1. Enable the `azure_ai_search` feature flag.
2. Set the Azure AI Search environment variables above.
3. Run `bundle exec rake azure_search:create_index`.
4. Run `bundle exec rake azure_search:index`.

After indexing, solution searches will query Azure AI Search instead of Contentful.

## Production

In production, solution search should be indexed regularly so the backend stays in sync with Contentful solution data.

The exact backend depends on which search path is enabled:

- Azure AI Search via `azure_ai_search`
- OpenSearch via `USE_OPENSEARCH`
- Contentful API search as the fallback
