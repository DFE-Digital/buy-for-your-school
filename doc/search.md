# Solution search

Buying solution search can use one of two backends:

- Contentful API search
- Azure AI Search, as the replacement path for solution search only

Category search still uses the Contentful API directly and is not indexed in Azure AI Search.

## Choosing the backend

The current selection order is:

1. Solution search uses Azure AI Search.
2. Category search uses the Contentful API.


## Azure AI Search

Azure AI Search is the preferred replacement for solution search.

It currently covers **solutions only**. Categories remain on the Contentful API.

### Environment variables

Azure AI Search uses:

- `AZURE_AI_SEARCH_ENDPOINT`
- `AZURE_AI_SEARCH_API_KEY`
- `AZURE_AI_SEARCH_QUERY_TYPE`
- `AZURE_AI_SEARCH_TOP`

Typical local or staging values are:

```sh
AZURE_AI_SEARCH_ENDPOINT=https://<your-search-service>.search.windows.net
AZURE_AI_SEARCH_API_KEY=<your-api-key>
AZURE_AI_SEARCH_QUERY_TYPE=simple
AZURE_AI_SEARCH_TOP=10
```

If semantic search is enabled on the Azure service, `AZURE_AI_SEARCH_QUERY_TYPE` can be set to `semantic`.
The index name (`contentful-data`) and semantic configuration (`contentful-v1`) are defined in code.

### Indexing solutions

Azure solution search is populated by:

```sh
bundle exec rake azure_ai_search:create_index
bundle exec rake azure_ai_search:index
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
bundle exec rake azure_ai_search:clear
```

And a task to delete the index entirely:

```sh
bundle exec rake azure_ai_search:delete_index
```


## Local development

To use Azure AI Search locally:

1. Set the Azure AI Search environment variables above.
2. Run `bundle exec rake azure_ai_search:create_index`.
3. Run `bundle exec rake azure_ai_search:index`.

After indexing, solution searches will query Azure AI Search instead of Contentful.

## Production

In production, the Contentful index is refreshed regularly so it stays in sync with Contentful solutions, referenced categories, and pages. This is handled by the scheduled background job `AzureAiSearch::ReindexJob`, which runs at midnight.
