import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="framework-edit"
export default class extends Controller {
    static targets = [ "input", "output", "hidden" ]
  
    connect() {
      if (this.hiddenTarget.value == "") {
        this.hideClearFrameworkLink();
      }
    }

    inputTargetConnected(element) {
      element.querySelector("input").addEventListener("change", this.toggle.bind(this));
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
      if (this.hiddenTarget.value !== "") {
        this.showClearFrameworkLink();
      } else {
        this.hideClearFrameworkLink();
      }
    }

    clearFramework(e) {
      e.preventDefault()
      this.inputTarget.querySelector("#framework-autocomplete").value = "";
      this.hiddenTarget.value = "";
      this.hideClearFrameworkLink();
    }
}
