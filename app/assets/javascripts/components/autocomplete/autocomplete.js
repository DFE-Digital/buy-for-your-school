//= require accessible-autocomplete/dist/accessible-autocomplete.min

(() => {

  /*
  Autocomplete
  ============

  This component provides a way to declaritively set up an autocomplete box in a simple way.
  It is build upon https://github.com/alphagov/accessible-autocomplete

  Component data attributes
  -------------------------

  This component will start working on its own if you define the following data attributes:

  - data-component:
    set to "autocomplete" to activate autocomplete component

  - data-autocomplete-element-id:
    the id of the resulting input field (useful for labels)

  - data-autocomplete-element-name:
    the name of the resulting form input element

  - data-autocomplete-template-suggestion:
    a string specifying the format you wish for the autocomplete choices
    to appear like. It makes use of {{variables}}.

    Given an API response of
    [{id: "1", name: "Joe Bloggs"}, {id: "2", "Jane Bloggs"}]

    And the template
    Id: {{id}} - <strong>{{name}}</strong>

    When the user types in the autocomplete box
    Then they will see the following choices
    Id: 1 - <strong>Joe Bloggs</strong>
    Id: 2 - <strong>Jane Bloggs</strong>

  - data-autocomplete-template-input:
    the value from the API response when chosen by the user will be the
    input value for this field

  - data-autocomplete-query-url:
    the URL of the endpoint you wish to get the autocomplete results from.
    It makes use of {{QUERY}} variable.

    Given a query url of http://example.org/cats?q={{QUERY}}
    When the user types "test" in the auto complete box
    Then the API will receive a GET request on http://example.org/cats?q=test

    It is worth utilising the rails helpers to build a url
    cats_url(format: :json, q: "{{QUERY}}")
  */

  const initializeAutocomplete = () => {
    // Set up an individual autocomplete field
    const initializeElement = element => {
      // Query an endpoint to return autocomplete choices
      const doQueryLookup = (query, populateResults) => {
        // Interpolate the user entered query into the provided query url
        const queryUrl = decodeURI(element.dataset.autocompleteQueryUrl)
          .replace("{{QUERY}}", query)

        fetch(queryUrl)
          .then(response => response.json())
          .then(populateResults);
      }

      // Format the autocomplete choice
      const formatSuggestion = (suggestion, template) => {
        output = template;

        Object.entries(suggestion).forEach(([key, value]) => {
          output = output.replace(new RegExp(`{{${key}}}`, 'g'), value);
        });

        return output;
      }

      // Construct the autocomplete initialization settings
      const settings = {
        element,
        id: element.dataset.autocompleteElementId,
        name: element.dataset.autocompleteElementName,
        minLength: 3,
        templates: {
          inputValue: i => i ? i[element.dataset.autocompleteTemplateInput] : undefined,
          suggestion: i => formatSuggestion(i, element.dataset.autocompleteTemplateSuggestion)
        },
        source: _.throttle(doQueryLookup)
      }

      // Initialize the autocomplete dependency
      accessibleAutocomplete(settings);
    }

    // Initialize each element with data-component set to autocomplete
    const elements = document.querySelectorAll('[data-component="autocomplete"]');
    elements.forEach(initializeElement);
  }

  document.addEventListener('DOMContentLoaded', initializeAutocomplete);

})();
