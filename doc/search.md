# Contentful search

Search uses one Azure AI Search query for solutions, categories, and pages, retaining Azure's relevance ordering.

## Azure AI Search

Azure AI Search provides the unified search index for Contentful content.

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

### Indexing Contentful content

The unified Contentful index is populated by:

```sh
bundle exec rake azure_ai_search:create_index
bundle exec rake azure_ai_search:index
```

The index task:

- creates or uses the Azure AI Search index
- fetches solutions, categories that have published solutions, and pages from Contentful
- bulk indexes the records into Azure AI Search

The Azure index stores a common shape across all three content types, including:

- id
- content type
- title
- description
- body (the solution summary, category body description, or page body)
- slug
- provider reference
- primary category

Search results are linked according to their content type: solutions to the buying option page, categories to the category landing page, and pages to their relevant slug.

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

After indexing, searches query Azure AI Search for solutions, categories, and pages.

## Production

In production, the Contentful index is refreshed regularly so it stays in sync with Contentful solutions, referenced categories, and pages. This is handled by the scheduled background job `AzureAiSearch::ReindexJob`, which runs at midnight.
