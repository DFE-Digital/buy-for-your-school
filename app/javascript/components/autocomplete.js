import accessibleAutocomplete from 'accessible-autocomplete';
import _ from "lodash";

(() => {

  /*
  Autocomplete
  ============

  See docs/components/autocomplete.md for full documentation.
  */

  const initializeAutocomplete = () => {
    // Set up an individual autocomplete field
    const initializeElement = element => {
      const {
        // id attribute for the autocomplete field
        autocompleteElementId: elementId,
        autocompleteContainerId: containerId,
        autocompleteContainerData: containerData,

        // name attribute for the autocomplete field
        autocompleteElementName: elementName,

        // The format applied to result suggestions with fields substituted
        autocompleteTemplateSuggestion: suggestionTemplate,

        // The key from the result object to use as the autocomplete field value
        autocompleteTemplateInput: valueKey,

        // The URL to query suggestions from {{QUERY}} will be substituted with the autocomplete field value
        autocompleteQueryUrl: queryUrl,

        // The default value of the autocomplete field before searching
        autocompleteDefaultValue: defaultValue,

        // key,value map of input name to result value and optional default value, each will become a hidden field on the form
        autocompleteHiddenFields: hiddenFieldsRaw,

        autocompleteTemplateField: templateField,
        autocompleteTemplates: templates
      } = element.dataset;

      // Query an endpoint to return autocomplete choices
      const doQueryLookup = (query, populateResults) => {
        // Interpolate the user entered query into the provided query url
        const formattedQueryUrl = decodeURI(queryUrl)
          .replace("{{QUERY}}", query)

        fetch(formattedQueryUrl)
          .then(response => response.json())
          .then(populateResults);
      }

      // Format the autocomplete choice
      const formatSuggestion = (suggestion, template) => {
        // Allow defaultValue to display
        if (_.isString(suggestion)) {
          return suggestion;
        }

        let output = template;

        Object.entries(suggestion).forEach(([key, value]) => {
          output = output.replace(new RegExp(`{{${key}}}`, 'g'), value);
        });

        return `<span class="govuk-body">${output}</span>`;
      }

      const determineTemplate = (suggestion, templateField, template) => {
        if (_.isString(suggestion) || _.isEmpty(templateField)) {
          return template;
        }

        const templateMap = JSON.parse(template);

        return templateMap[suggestion[templateField]];
      }

      // Set the hidden field values on selection of suggestion
      const setHiddenFields = (result) => {
        if (result === undefined) return;
        if (hiddenFieldsRaw === null || hiddenFieldsRaw === '') return;

        const hiddenFieldsMap = JSON.parse(hiddenFieldsRaw);

        Object.entries(hiddenFieldsMap).forEach(([fieldName, keyOrKeyAndDefault]) => {
          const key = Array.isArray(keyOrKeyAndDefault) ? keyOrKeyAndDefault[0] : keyOrKeyAndDefault
          const hiddenField = document.querySelector(`input[name="${fieldName}"]`);
          hiddenField.value = result[key];
        });
      }

      // Construct the autocomplete initialization settings
      const sourceInputAttributes = {
        className: element.className,
        ariaDescribedBy: element.getAttribute("aria-describedby"),
        ariaInvalid: element.getAttribute("aria-invalid"),
        dataAttributes: Array.from(element.attributes).filter(attribute => attribute.name.startsWith("data-"))
      };

      const container = document.createElement("div");
      if (containerId) container.id = containerId;
      Object.entries(JSON.parse(containerData || "{}")).forEach(([name, value]) => {
        const datasetName = name.replace(/_([a-z])/g, (_match, character) => character.toUpperCase());
        container.dataset[datasetName] = value;
      });
      element.parentNode.replaceChild(container, element);

      const settings = {
        element: container,
        id: elementId,
        name: elementName,
        minLength: 3,
        defaultValue: defaultValue,
        confirmOnBlur: false,
        templates: {
          inputValue: i => i ? i[valueKey] : undefined,
          suggestion: i => {
            const template = templates ? determineTemplate(i, templateField, templates) : suggestionTemplate;
            return formatSuggestion(i, template);
          }
        },
        source: _.throttle(doQueryLookup),
        onConfirm: setHiddenFields,
        tStatusNoResults: () => "No results found"
      }

      // Initialize the autocomplete dependency
      accessibleAutocomplete(settings);

      const autocompleteInput = document.getElementById(elementId);
      if (autocompleteInput) {
        autocompleteInput.className = `${autocompleteInput.className} ${sourceInputAttributes.className}`.trim();
        if (sourceInputAttributes.ariaDescribedBy) {
          autocompleteInput.setAttribute("aria-describedby", sourceInputAttributes.ariaDescribedBy);
        }
        if (sourceInputAttributes.ariaInvalid) {
          autocompleteInput.setAttribute("aria-invalid", sourceInputAttributes.ariaInvalid);
        }
        sourceInputAttributes.dataAttributes.forEach(attribute => {
          autocompleteInput.setAttribute(attribute.name, attribute.value);
        });
      }
    }

    // Initialize each element with data-component set to autocomplete
    const elements = document.querySelectorAll('[data-component="autocomplete"]');
    elements.forEach(initializeElement);
  }

  document.addEventListener('DOMContentLoaded', initializeAutocomplete);

})();
