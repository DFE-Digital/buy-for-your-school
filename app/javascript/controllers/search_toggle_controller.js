import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['openButton', 'closeButton']
  static classes = ['hidden']

  connect () {
    // Ensure initial state
    this.openButtonTarget.classList.remove(this.hiddenClass) // Make sure open button is visible
    this.closeButtonTarget.classList.add(this.hiddenClass) // Make sure close button is hidden
  }

  toggleOpen () {
    this.openButtonTarget.classList.add(this.hiddenClass)
    this.closeButtonTarget.classList.remove(this.hiddenClass)
  }

  toggleClose () {
    this.openButtonTarget.classList.remove(this.hiddenClass)
    this.closeButtonTarget.classList.add(this.hiddenClass)
  }
}
