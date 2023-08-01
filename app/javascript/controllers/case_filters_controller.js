import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="case-filters"
export default class extends Controller {
  connect() {
    this.assignInputChangeHandlers(this.element, "checkbox");
    this.assignInputChangeHandlers(this.element, "radio");
    this.assignSelectChangeHandlers(this.element);
  }

  assignInputChangeHandlers(element, type) {
    const inputs = element.querySelectorAll(`[type='${type}']`);
    inputs.forEach(input => input.addEventListener("change", this.onChange.bind(this)));
  }

  assignSelectChangeHandlers(element) {
    const selects = element.querySelectorAll("select");
    selects.forEach(select => select.addEventListener("change", this.onChange.bind(this)));
  }

  onChange(e) {
    this.element.requestSubmit();
  }
}
