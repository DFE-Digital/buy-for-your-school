import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date_validation"
export default class extends Controller {
  static targets = ["dateValidation"]

  connect() {
    const submitButton = this.dateValidationTarget.querySelector('form input[type=submit].validate_date');
    const dateInputs = this.dateValidationTarget.querySelectorAll('.govuk-form-group .govuk-date-input');
  
    submitButton.addEventListener("click", (e) => {
      e.preventDefault();
      this.removeErrorFieldStyle();
      let isValid = true;
      e.target.blur();
  
      dateInputs.forEach((dateGroup, index) => {
        const [dayInput, monthInput, yearInput] = dateGroup.querySelectorAll('.govuk-date-input__input');
        const day = parseInt(dayInput.value, 10);
        const year = parseInt(yearInput.value, 10);
        const monthData = monthInput.value;
  
        const { date, validMonth, convertedMonth } = this.processDate(day, monthData, year);
  
        if (validMonth) {
          monthInput.value = convertedMonth; // Update month input if valid
        }
  
        if (!this.isDateValid(date, day, year, validMonth) && dayInput.value && monthInput.value && yearInput.value) {
          isValid = false;
          this.setErrorFieldStyle(dateGroup, index);
        }
      });
  
      if (isValid) {
        this.dateValidationTarget.querySelector('form').submit();
      }
    });
  }
  
  processDate(day, monthData, year) {
    if (this.checkValidMonthFormat(monthData)) {
      const date = new Date(`${day} ${monthData} ${year}`);
      return {
        date,
        validMonth: true,
        convertedMonth: date.getMonth() + 1 // Convert to 1-indexed month
      };
    } else {
      const month = parseInt(monthData, 10) - 1; // Convert to 0-indexed month
      const date = new Date(year, month, day);
      return {
        date,
        validMonth: date.getMonth() === month,
        convertedMonth: date.getMonth() + 1
      };
    }
  }
  
  isDateValid(date, day, year, validMonth) {
    return date.getFullYear() === year && validMonth && date.getDate() === day;
  }

  checkValidMonthFormat(month) {  
    const validMonths = [
      "jan", "january",
      "feb", "february",
      "mar", "march",
      "apr", "april",
      "may",
      "jun", "june",
      "jul", "july",
      "aug", "august",
      "sep", "september",
      "oct", "october",
      "nov", "november",
      "dec", "december"
    ];

    return validMonths.includes(month.toLowerCase());
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
