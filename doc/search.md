# Solution search

Find a buying solution search can use OpenSearch to search indexed Contentful solutions, or a direct search via the Contentful API. The OpenSearch approach is preferred and yield a better search experience. Categories are always searched directly via the Contentful API and are not indexed in OpenSearch.

## Enabling OpenSearch

OpenSearch-backed solution search is enabled when:

- `USE_OPENSEARCH` is set to `true`
- either `OPENSEARCH_URL` or `BONSAI_URL` points to an OpenSearch instance

When `USE_OPENSEARCH` is not `true`, solution search falls back to Contentful search.

The search client reads the OpenSearch URL from:

```ruby
ENV["OPENSEARCH_URL"] || ENV["BONSAI_URL"]
```

## Bonsai and Azure

FABS historically used the Bonsai service running on Heroku for search. The migrated solution search still supports that service for now through
`BONSAI_URL`.

This is temporary. Once OpenSearch infrastructure is available on Azure, the service should use `OPENSEARCH_URL` instead. At that point `BONSAI_URL` can be removed.

## Indexing solutions

The OpenSearch index is populated by the rake task:

```sh
bundle exec rake search:index
```

The task:

- creates the `solution-data` index if it does not already exist
- fetches solutions from Contentful
- bulk indexes each solution into OpenSearch

The indexed solution data includes:

- id
- title
- description
- summary
- slug
- provider reference
- primary category

## Local development

To use OpenSearch locally:

1. Set `USE_OPENSEARCH=true`.
2. Set `OPENSEARCH_URL` or `BONSAI_URL` to a local or remote OpenSearch
   instance.
3. Run `bundle exec rake search:index` to create and populate the index.

After indexing, solution searches will query OpenSearch instead of Contentful.

### macOS with Homebrew

On macOS, OpenSearch can be installed with Homebrew:

```sh
brew install opensearch
brew services start opensearch
```

Once OpenSearch is running, set `OPENSEARCH_URL` to the local instance URL,
for example:

```sh
OPENSEARCH_URL=http://localhost:9200
```

Then run:

```sh
bundle exec rake search:index
```

## Production

In production, `search:index` runs every hour to keep OpenSearch in sync with Contentful solution data.

Until Azure OpenSearch infrastructure is in place, production can continue to use Bonsai via `BONSAI_URL`. After the Azure migration, production should use `OPENSEARCH_URL`.
