import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="school-picker"
export default class extends Controller {
  static targets = [
    "selectedCount",
    "selectAll",
    "schoolTableBody",
  ];
  static values = { scope: String };

  initialize() {
    this.getPreviouslySelectedSchoolUrns().forEach(urn => {
      const input = document.createElement("input");
      input.setAttribute("type", "hidden");
      input.setAttribute("name", `${this.scopeValue}[school_urns][]`);
      input.setAttribute("value", urn);
      this.getForm().appendChild(input);
    });
  }

  connect() {
    this.refreshSelectAll();
    this.refreshSelectedCount();
  }

  toggleSelectAll(e) {
    this.schoolCheckboxes().forEach(school => school.checked = e.target.checked);
    this.refreshSelectedCount();
  }

  toggleSelection() {
    this.refreshSelectAll();
    this.refreshSelectedCount();
  }

  refreshSelectAll() {
    this.selectAllTarget.checked = this.allSelected();
  }

  refreshSelectedCount() {
    this.selectedCountTarget.innerText = this.getSchoolUrnsFromForm().length;
  }

  schoolCheckboxes() {
    return Array.from(this.schoolTableBodyTarget.querySelectorAll("tr:not([style*='visibility: collapse']) input[type='checkbox']"));
  }

  allSelected() {
    return this.schoolCheckboxes().every(c => c.checked);
  }

  getSchoolUrns() {
    return this.getSchoolUrnsFromForm();
  }

  getPreviouslySelectedSchoolUrns() {
    return this.getSchoolUrnsFromParams().filter(urn => !this.getSchoolUrnsFromForm().includes(urn));
  }

  getSchoolUrnsFromForm() {
    return new FormData(this.getForm()).getAll(`${this.scopeValue}[school_urns][]`).filter(urn => urn && urn !== "all");
  }

  getSchoolUrnsFromParams() {
    const params = new URLSearchParams(window.location.search);
    return params.getAll(`${this.scopeValue}[school_urns][]`);
  }

  getForm() {
    return this.element.parentElement;
  }
}
