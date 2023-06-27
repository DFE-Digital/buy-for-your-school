import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="email-templates-select"
export default class extends Controller {
  static targets = ["btnUseTemplate"];

  onTemplateSelected(e) {
    this.btnUseTemplateTarget.removeAttribute("disabled");
  }
}
