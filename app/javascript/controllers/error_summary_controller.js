import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title",
    "body"
  ]

  initialize() {
    this.errorMessages = []
  }

  reset() {
    this.errorMessages = []
    this.render()
  }

  addError(errorMessage) {
    this.errorMessages.push(errorMessage)
    this.render()
  }

  removeError(errorMessage) {
    this.errorMessages = this.errorMessages.filter(error => error != errorMessage)
    this.render()
  }

  render() {
    this.bodyTarget.innerHTML = `
      <ul class="govuk-list govuk-error-summary__list">
        ${this.errorMessages.map(error => `<li><a href="#">${error}</a></li>`).join("\n")}
      </ul>
    `

    this.display(this.element, this.errorMessages.length > 0)
  }

  display(element, isVisible) {
    element.classList.remove('govuk-!-display-none')

    if (!isVisible)
      element.classList.add('govuk-!-display-none')
  }
}
