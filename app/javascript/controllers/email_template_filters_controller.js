import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="email-template-filters"
export default class extends Controller {
  connect() {
    this.assignCheckboxHandlers(this.element);
  }

  assignCheckboxHandlers(element) {
    const checkboxes = element.querySelectorAll("[type='checkbox']");
    checkboxes.forEach(checkbox => checkbox.addEventListener("change", this.onFilterChange.bind(this)));
  }

  onFilterChange(e) {
    this.element.requestSubmit();
  }
}
