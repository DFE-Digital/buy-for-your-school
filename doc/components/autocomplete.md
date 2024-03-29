# Autocomplete

A glue layer to make using [alphagov/accessible-autocomplete](https://github.com/alphagov/accessible-autocomplete/) a breeze.

## Typical usage

Using specified data attributes on a html tag will activate the autocomplete. A fallback field can be specified to cater for users without javascript capability.

#### Using the component partial:

```erb
<%= render "components/autocomplete",
            label_text: "Establishment URN",
            element_id: "my-autocomplete",
            element_name: "case_form[school_urn]",
            template_suggestion: "URN: {{urn}}, <strong>{{name}}</strong>, {{postcode}}",
            value_field: :urn,
            hidden_fields: {
              "my_form[org_id]" => :id,
              "my_form[org_postcode] => :postcode"
            },
            query_url: support_schools_path(format: :json, q: "{{QUERY}}") do %>
  <%= f.govuk_text_field :school_urn, label: { text: "Establishment URN" } %>
<% end %>
```

## Partial attribute documentation

|Attribute|Description|Example configuration|
|--|--|--|
| `container_id` | the id of the element that will become the autocomplete field | "any-id-here" |
| `label_text` | The text to be used in the resulting field label | "Establishment URN" |
| `element_id` | The id attribute of the resulting input field | "my-autocomplete" |
| `element_name` | The name attribute of the resulting input field | "case_form[school_urn]" |
| `template_suggestion` | a string specifying the format you wish for the autocomplete choices to appear |  like. It makes use of {{variables}}. See [below](#template-suggestion-syntax) | "The URN is {{urn}}" |
| `value_field` | the value from the API response when chosen by the user will be the input value for this field |  "name" |
| `hidden_fields` | key,value map for auto generating hidden fields. You can also specify default values using the array syntax. See [below](#hidden-fields) | `{"my_form[org_id]" => :id, "my_form[org_postcode] => :postcode"}`<br>or<br>`{"my_form[org_id]" => [:id, "DEFAULT_ID"], "my_form[org_postcode]" => [:postcode, "DEFAULT_POSTCODE"]}` |
| `query_url` | the URL of the endpoint you wish to get the autocomplete results from. It makes use of {{QUERY}} variable. See [below](#query-url-syntax) | "http://example.org/cats?query={{QUERY}}" |
| Partial Block | A block given to the partial to define the fallback non-js input field to be used | |


### Template suggestion syntax

```
Given an API response of
[{id: "1", name: "Joe Bloggs"}, {id: "2", name: "Jane Bloggs"}]

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

### Hidden fields

By default the autocomplete form will send a single form value (sent as `element_name`).

If you want to send more values to the server, you can do so with hidden fields.

||Description|
|-|-|
|key|This is the name of the hidden field that will be generated in the form|
|value|The hidden field will be populated with this field from the response json|

```
Given an API response of
[{id: "1", name: "Joe Bloggs", age: 20}, {id: "2",  name: "Jane Bloggs", age: 32}]

And the element_name is set to user_form[name]

And the hidden fields are setup like so:
{"user_form[id]" => :id, "user_form[age]" => :age}

When the user selects Joe Bloggs
And submits the form

Then the server has the following params
{
  user_form: {
    name: "Joe Bloggs",     # default autocomplete field
    id: "1",                # hidden field
    age: 20                 # hidden field
  }
}
```
