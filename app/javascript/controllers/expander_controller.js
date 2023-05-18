import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="expander"
export default class extends Controller {
  static targets = [ "expander", "chevron", "content" ];
  static values = { expanded: Boolean };

  connect() {
    this.setExpanded(this.expandedValue);
    this.setDisabled(this.isDisabled());
  }

  isDisabled() {
    return this.expanderTarget.hasAttribute("disabled");
  }

  isExpanded() {
    return this.expanderTarget.classList.contains("expander__expanded");
  }

  setExpanded(expanded) {
    if (expanded) {
      this.expanderTarget.classList.add("expander__expanded");
      this.chevronTarget.classList.add("expander__chevron--down");
      this.contentTarget.classList.remove("govuk-!-display-none");
    } else {
      this.expanderTarget.classList.remove("expander__expanded");
      this.chevronTarget.classList.remove("expander__chevron--down");
      this.contentTarget.classList.add("govuk-!-display-none");
    }
    this.contentTarget.setAttribute("aria-expanded", expanded.toString());
  }

  toggleContent() {
    if (this.isDisabled()) {
      return;
    }

    this.setExpanded(!this.isExpanded());
  }

  setDisabled(disabled) {
    if (disabled) {
      this.expanderTarget.setAttribute("disabled", disabled);
    } else {
      this.expanderTarget.removeAttribute("disabled");
    }

    this.expanderTarget.setAttribute("aria-disabled", disabled);
  }
}
