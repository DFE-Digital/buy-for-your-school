import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="school-picker-filters"
export default class extends Controller {
  static targets = ["schoolUrns"]
  static outlets = ["school-picker"]

  connect() {
    this.assignCheckboxHandlers(this.element);
  }

  assignCheckboxHandlers(element) {
    const checkboxes = element.querySelectorAll("input[type='checkbox']");
    checkboxes.forEach(checkbox => checkbox.addEventListener("change", this.onFilterChange.bind(this)));
  }

  onFilterChange() {
    this.setSchoolUrns();
    this.element.requestSubmit();
  }

  setSchoolUrns() {
    this.schoolPickerOutlet.getSchoolUrns().forEach(urn => {
      const input = document.createElement("input");
      input.setAttribute("type", "hidden");
      input.setAttribute("name", "framework_support_form[school_urns][]");
      input.setAttribute("value", urn);
      this.element.appendChild(input);
    });
  }
}
