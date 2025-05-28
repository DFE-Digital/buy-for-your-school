import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="electricity_meter_conditional_option"
export default class extends Controller {
    static targets = [ "input", "output" ]
  
    connect() {
      this.inputTarget.querySelectorAll('.govuk-radios__input').forEach((radioButton) => {
        radioButton.addEventListener("change", this.toggle.bind(this));
      })
    }

    hideTextField() {
      this.outputTarget.classList.add("govuk-!-display-none");

      this.outputTarget.querySelectorAll('input').forEach((input) => {
        input.value = '';
        input.classList.remove('govuk-input--error');
      })
    }  

    showTextField() {
      this.outputTarget.classList.remove("govuk-!-display-none");
    }
  
    toggle() {
      if (this.inputTarget.querySelector('.govuk-radios__input:checked').value === "true") {
        this.showTextField();
      } else {
        this.hideTextField();
      }
    }
  }