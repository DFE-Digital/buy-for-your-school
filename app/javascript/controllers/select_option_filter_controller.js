import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select-option-filter"
export default class extends Controller {
  static targets = ["input", "output"]
  static values = { paramName: String }

  connect() {
    this.inputTarget.addEventListener("change", this.updateOutputList.bind(this));
  }

  updateOutputList() {
    this.outputTarget.value = "";

    this.outputTarget
      .querySelectorAll(`option`)
      .forEach(element => element.hidden = element.dataset[this.paramNameValue] != this.inputTarget.value)
  }
}
