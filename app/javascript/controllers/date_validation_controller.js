import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date_validation"
export default class extends Controller {
  static targets = ["dateValidation"]

  connect() {
    this.dateValidationTarget.querySelector('form input[type=submit].validate_date').addEventListener("click", (e) => {
      e.preventDefault();
      this.removeErrorFieldStyle();
      let isValid = true;
      e.target.blur()
  
      this.dateValidationTarget.querySelectorAll('.govuk-form-group .govuk-date-input').forEach((dateGroup, index) => {

        const day = parseInt(dateGroup.querySelectorAll('.govuk-date-input__input')[0].value, 10);
        const month = parseInt(dateGroup.querySelectorAll('.govuk-date-input__input')[1].value, 10) - 1; // Months are 0-indexed in JS
        const year = parseInt(dateGroup.querySelectorAll('.govuk-date-input__input')[2].value, 10);

        // Check if the date is valid
        const date = new Date(year, month, day);
        if (date.getFullYear() !== year || date.getMonth() !== month || date.getDate() !== day) {
          isValid = false;
          this.setErrorFieldStyle(dateGroup, index);
        }
      });

      if (isValid) {
        this.dateValidationTarget.querySelector('form').submit();
      }
    });
  }

  setErrorFieldStyle(dateGroup, index) {
    dateGroup.querySelectorAll('.govuk-date-input__input').forEach(input => {
      input.classList.add('govuk-input--error');
    });
    dateGroup.closest('.govuk-form-group').classList.add('govuk-form-group--error');

    const errorMessages = JSON.parse(this.dateValidationTarget.getAttribute('date-validation-error-messages'));
    const errorElement = document.createElement('p');

    errorElement.classList.add('govuk-error-message');
    errorElement.innerHTML = errorMessages[index];

    dateGroup.insertAdjacentElement('beforebegin', errorElement);
  }

  removeErrorFieldStyle() {
    this.dateValidationTarget.querySelectorAll('.govuk-form-group .govuk-date-input').forEach(dateGroup => {
      dateGroup.querySelectorAll('.govuk-date-input__input').forEach(input => {
        input.classList.remove('govuk-input--error');
      });
      dateGroup.closest('.govuk-form-group').classList.remove('govuk-form-group--error');
    });

    this.dateValidationTarget.querySelectorAll('.govuk-error-message').forEach(errorElement => {
      errorElement.remove();
    });
  }

}
