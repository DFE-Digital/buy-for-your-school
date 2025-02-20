import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="download_documents"
export default class extends Controller {
  static targets = ["downloadLinks"]

  connect() {
    this.downloadLinksTarget.querySelectorAll('.govuk-link').forEach(link => {
      link.addEventListener("click", (e) => {
        e.target.closest('.govuk-summary-list__row').querySelector('.downloaded-icon').classList.remove('govuk-!-display-none');
      });
    });
  }

}
