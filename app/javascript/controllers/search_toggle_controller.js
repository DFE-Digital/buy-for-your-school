import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['openButton', 'closeButton', 'backgroundColor']

  connect () {
    this.hiddenClassName = this.element.dataset.searchToggleHiddenClass
    this.backgroundClassName = this.element.dataset.searchToggleBackgroundClass
    this.visibleClassName = this.element.dataset.searchToggleVisibleClass

    // Get the search box element
    this.searchBox = document.getElementById('wrap-search')
    this.searchArea = document.querySelector('.search-area')

    // Ensure initial state
    if (this.openButtonTarget) {
      this.openButtonTarget.classList.remove(this.hiddenClassName)
    }
    if (this.closeButtonTarget) {
      this.closeButtonTarget.classList.add(this.hiddenClassName)
    }
    if (this.searchBox) {
      this.searchBox.classList.add(this.hiddenClassName)
      this.searchBox.classList.remove(this.visibleClassName)
    }
  }

  toggleOpen () {
    if (this.openButtonTarget) {
      this.openButtonTarget.classList.add(this.hiddenClassName)
    }
    if (this.closeButtonTarget) {
      this.closeButtonTarget.classList.remove(this.hiddenClassName)
    }
    if (this.searchBox) {
      this.searchBox.classList.remove(this.hiddenClassName)
      this.searchBox.classList.add(this.visibleClassName)
    }
    if (this.searchArea) {
      this.searchArea.classList.add(this.backgroundClassName)
    }
    if (this.hasBackgroundColorTarget) {
      this.backgroundColorTarget.classList.add(this.backgroundClassName)
    }
  }

  toggleClose () {
    if (this.openButtonTarget) {
      this.openButtonTarget.classList.remove(this.hiddenClassName)
    }
    if (this.closeButtonTarget) {
      this.closeButtonTarget.classList.add(this.hiddenClassName)
    }
    if (this.searchBox) {
      this.searchBox.classList.add(this.hiddenClassName)
      this.searchBox.classList.remove(this.visibleClassName)
    }
    if (this.searchArea) {
      this.searchArea.classList.remove(this.backgroundClassName)
    }
    if (this.hasBackgroundColorTarget) {
      this.backgroundColorTarget.classList.remove(this.backgroundClassName)
    }
  }
}
