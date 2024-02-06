import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="framework-edit"
export default class extends Controller {
    static targets = [ "input", "output", "hidden" ]
  
    connect() {
      if (this.hiddenTarget.value == "") {
        this.hideClearFrameworkLink();
      }
      this.inputTarget.addEventListener("change", this.toggle.bind(this));
    }

    hideClearFrameworkLink() {
      this.outputTarget.classList.add("govuk-!-display-none");
      this.outputTarget.setAttribute("disabled", true);
    }  

    showClearFrameworkLink() {
      this.outputTarget.classList.remove("govuk-!-display-none");
      this.outputTarget.removeAttribute("disabled");
    }
  
    toggle() {
      if (this.hiddenTarget.value != null) {
        this.showClearFrameworkLink();
      }
    }

    clearFramework(e) {
      e.preventDefault()
      this.inputTarget.querySelector("#framework-autocomplete").value = "";
      this.hiddenTarget.value = null;
      this.hideClearFrameworkLink();
    }
}
