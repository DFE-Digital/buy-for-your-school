import { Controller } from "@hotwired/stimulus"
import { enable } from "../misc/utilities"

// Connects to data-controller="checklist-table"
export default class extends Controller {
  static targets = [
    "selectedCount",
    "selectAll",
    "tableBody",
    "form",
    "submit"
  ];
  static values = {
    scope: String,
    checklistField: String,
    countPhrase: String,
    countPhraseNoun: String
  };

  initialize() {
    this.getPreviouslySelectedChecklistValues().forEach(value => {
      const input = document.createElement("input");
      input.setAttribute("type", "hidden");
      input.setAttribute("name", `${this.scopeValue}[${this.checklistFieldValue}][]`);
      input.setAttribute("value", value);
      this.formTarget.appendChild(input);
    });
  }

  connect() {
    if (this.hasSelectAllTarget) {
      this.refreshSelectAll();
    }
    this.refreshSelectedCount();
    this.toggleSubmitEnabled();
  }

  toggleSelectAll(e) {
    this.checkboxes().forEach(school => school.checked = e.target.checked);
    this.refreshSelectedCount();
    this.toggleSubmitEnabled();
  }

  toggleSelection() {
    this.refreshSelectAll();
    this.refreshSelectedCount();
    this.toggleSubmitEnabled();
  }

  refreshSelectAll() {
    this.selectAllTarget.checked = this.allSelected();
  }

  refreshSelectedCount() {
    this.selectedCountTarget.innerText = this.generateCountPhrase(this.getChecklistValuesFromForm().length);
  }

  toggleSubmitEnabled() {
    enable(this.submitTarget, this.getChecklistValuesFromForm().length > 0)
  }

  generateCountPhrase(count) {
    const noun = count != 1 ? `${this.countPhraseNounValue}s` : this.countPhraseNounValue;
    const phrase = this.countPhraseValue.replace(/{{count}}/, count).replace(/{{noun}}/, noun)
    return phrase;
  }

  checkboxes() {
    return Array.from(this.tableBodyTarget.querySelectorAll("input[type='checkbox']"));
  }

  allSelected() {
    return this.checkboxes().every(c => c.checked);
  }

  getChecklistValues() {
    return this.getChecklistValuesFromForm();
  }

  getPreviouslySelectedChecklistValues() {
    return this.getChecklistValuesFromParams().filter(value => !this.getChecklistValuesFromForm().includes(value));
  }

  getChecklistValuesFromForm() {
    return new FormData(this.formTarget).getAll(`${this.scopeValue}[${this.checklistFieldValue}][]`).filter(value => value && value !== "all");
  }

  getChecklistValuesFromParams() {
    const params = new URLSearchParams(this.formTarget.closest("turbo-frame").src);
    return params.getAll(`${this.scopeValue}[${this.checklistFieldValue}][]`);
  }
}
