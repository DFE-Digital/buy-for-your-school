import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['openButton', 'closeButton', 'backgroundColor']
  static classes = ['hidden']

  connect () {
    // Get the hidden class from data attribute (defaults to 'is-not-visible')
    // data-search-toggle-hidden-class becomes searchToggleHiddenClass in dataset
    this.hiddenClassName = this.element.dataset.searchToggleHiddenClass || 'is-not-visible'
    this.backgroundClassName = this.element.dataset.searchToggleBackgroundClass || 'search-header-background'
    
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
    }
    if (this.searchArea) {
      this.searchArea.classList.remove(this.backgroundClassName)
    }
    if (this.hasBackgroundColorTarget) {
      this.backgroundColorTarget.classList.remove(this.backgroundClassName)
    }
  }
}
