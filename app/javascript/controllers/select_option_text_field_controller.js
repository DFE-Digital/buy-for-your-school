import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select-option-text-field"
export default class extends Controller {
    static targets = [ "input", "output" ]
    static values = { showIf: String }
  
    connect() {
      this.inputTarget.addEventListener("change", this.toggle.bind(this));
      this.hideTextField();
    }

    hideTextField() {
      this.outputTarget.value = "";
      this.outputTarget.classList.add("govuk-!-display-none");
      this.outputTarget.setAttribute("disabled", true);
      this.outputTarget.parentNode.childNodes[0].classList.add("govuk-!-display-none");
    }  

    showTextField() {
      this.outputTarget.classList.remove("govuk-!-display-none");
      this.outputTarget.removeAttribute("disabled");
      this.outputTarget.parentNode.childNodes[0].classList.remove("govuk-!-display-none");
    }
  
    toggle() {
      if (this.inputTarget.value != this.showIfValue) {
        this.hideTextField();
      } else if (this.inputTarget.value = this.showIfValue) {
        this.showTextField();
      }
    }
  }