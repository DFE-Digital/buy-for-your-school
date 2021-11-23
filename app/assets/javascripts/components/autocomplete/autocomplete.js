//= require accessible-autocomplete/dist/accessible-autocomplete.min

(() => {

  /*
  Autocomplete
  ============

  See docs/components/autocomplete.md for full documentation.
  */

  const initializeAutocomplete = () => {
    // Set up an individual autocomplete field
    const initializeElement = element => {
      // Set up the required markup to make the autocomplete element function
      // and fit in with govuk style standards
      const setupFormGroupAndLabel = () => {
        const formGroup = document.createElement('div');
        formGroup.classList.add('govuk-form-group');

        const formLabel = document.createElement('label');
        formLabel.classList.add('govuk-label');
        formLabel.setAttribute('for', element.dataset.autocompleteElementId);
        formLabel.textContent = element.dataset.autocompleteLabelText;

        const currentElementParent = element.parentNode;
        currentElementParent.replaceChild(formGroup, element);

        formGroup.appendChild(formLabel);
        formGroup.appendChild(element);
      }

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

        return `<span class="govuk-body">${output}</span>`;
      }

      // Construct the autocomplete initialization settings
      const settings = {
        element,
        id: element.dataset.autocompleteElementId,
        name: element.dataset.autocompleteElementName,
        minLength: 3,
        defaultValue: element.dataset.autocompleteDefaultValue,
        templates: {
          inputValue: i => i ? i[element.dataset.autocompleteTemplateInput] : undefined,
          suggestion: i => formatSuggestion(i, element.dataset.autocompleteTemplateSuggestion)
        },
        source: _.throttle(doQueryLookup)
      }

      setupFormGroupAndLabel();

      // Initialize the autocomplete dependency
      accessibleAutocomplete(settings);
    }

    // Initialize each element with data-component set to autocomplete
    const elements = document.querySelectorAll('[data-component="autocomplete"]');
    elements.forEach(initializeElement);
  }

  document.addEventListener('DOMContentLoaded', initializeAutocomplete);

})();
