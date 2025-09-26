import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.querySelectorAll('details.govuk-details > .govuk-details__summary').forEach(link => {
      const details = link.parentElement;
      this.setAriaHidden(details, true);
      link.addEventListener('click', () => this.toggleAriaHidden(details));
    });
  }

  toggleAriaHidden(details) {
    const isOpen = details.hasAttribute('open');
    this.setAriaHidden(details, isOpen);
  }

  setAriaHidden(details, hidden) {
    const content = details.querySelector('.govuk-details__text');
    content.setAttribute('aria-hidden', hidden.toString());
  }
}