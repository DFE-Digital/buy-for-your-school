import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const radioButtons = this.element.querySelectorAll('[type="radio"]')
    radioButtons.forEach(radio => radio.addEventListener('change', this.onFilterChange.bind(this)))
  }

  onFilterChange(e) {
    this.element.requestSubmit()
  }
}
