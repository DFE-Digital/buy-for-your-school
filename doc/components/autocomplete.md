# Autocomplete

A glue layer to make using [alphagov/accessible-autocomplete](https://github.com/alphagov/accessible-autocomplete/) a breeze.

## Typical usage

Using specified data attributes on a html tag will activate the autocomplete.
Please note use of `noscript` as a fallback mechanism for those with javascript disabled.

```erb
<div
  id="my-autocomplete-container"
  data-component="autocomplete"
  data-autocomplete-label-text="Establishment URN"
  data-autocomplete-element-id="my-autocomplete"
  data-autocomplete-element-name="case_form[school_urn]"
  data-autocomplete-template-suggestion='URN: {{urn}}, <strong>{{name}}</strong>, {{postcode}}'
  data-autocomplete-template-input="urn"
  data-autocomplete-query-url="<%= support_schools_path(format: :json, q: "{{QUERY}}") %>">
</div>

<noscript>
  <%= f.govuk_text_field :school_urn, label: { text: "Establishment URN" } %>
</noscript>
```

## Data attribute documentation

|data-attribute|Description|Example configuration|
|--|--|--|
| `data-component` | set to "autocomplete" to activate autocomplete component | "autocomplete" only |
| `data-autocomplete-label-text` | The text to be used in the resulting field label | "Establishment URN" |
| `data-autocomplete-element-id` | The id attribute of the resulting input field | "my-autocomplete" |
| `data-autocomplete-element-name` | The name attribute of the resulting input field | "case_form[school_urn]" |
| `data-autocomplete-template-suggestion` | a string specifying the format you wish for the autocomplete choices to appear like. It makes use of {{variables}}. See [below](#template-suggestion-syntax) | "The URN is {{urn}}" |
| `data-autocomplete-template-input` | the value from the API response when chosen by the user will be the input value for this field | "urn" |
| `data-autocomplete-query-url` | the URL of the endpoint you wish to get the autocomplete results from. It makes use of {{QUERY}} variable. See [below](#query-url-syntax) | "http://example.org/cats?query={{QUERY}}" |


### Template suggestion syntax

```
Given an API response of
[{id: "1", name: "Joe Bloggs"}, {id: "2", "Jane Bloggs"}]

And the template
Id: {{id}} - <strong>{{name}}</strong>

When the user types in the autocomplete box
Then they will see the following choices
Id: 1 - <strong>Joe Bloggs</strong>
Id: 2 - <strong>Jane Bloggs</strong>
```

### Query url syntax

```
Given a query url of http://example.org/cats?q={{QUERY}}
When the user types "test" in the auto complete box
Then the API will receive a GET request on http://example.org/cats?q=test
```

It is worth utilising the rails helpers to build a url:

```ruby
cats_url(format: :json, q: "{{QUERY}}") # => http://example.org/cats.json?q={{QUERY}}
```