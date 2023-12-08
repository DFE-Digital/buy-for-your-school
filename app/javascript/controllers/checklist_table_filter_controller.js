import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checklist-table-filter"
export default class extends Controller {
  static outlets = ["checklist-table"]
  static values = { scope: String, checklistField: String };

  connect() {
    this.assignFilterHandlers();
  }

  assignFilterHandlers() {
    const inputs = this.element.querySelectorAll("[type='radio']");
    inputs.forEach(input => input.addEventListener("change", this.onFilterChange.bind(this)));
  }

  onFilterChange() {
    this.setChecklistValues();
    this.element.requestSubmit();
  }

  setChecklistValues() {
    this.checklistTableOutlet.getChecklistValues().forEach(value => {
      const input = document.createElement("input");
      input.setAttribute("type", "hidden");
      input.setAttribute("name", `${this.scopeValue}[${this.checklistFieldValue}][]`);
      input.setAttribute("value", value);
      this.element.appendChild(input);
    });
  }
}
