import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "navigationButton",
    "navigationLink",
    "navigationMenu",
    "searchButton",
    "searchLink",
    "searchMenu"
  ]

  connect () {
    this.hidePanel(this.navigationButtonTarget, this.navigationMenuTarget)
    this.hidePanel(this.searchButtonTarget, this.searchMenuTarget)

    if (this.hasNavigationLinkTarget) {
      this.navigationLinkTarget.hidden = true
    }

    if (this.hasSearchLinkTarget) {
      this.searchLinkTarget.hidden = true
    }

    this.navigationButtonTarget.hidden = false
    this.searchButtonTarget.hidden = false
  }

  toggleNavigation () {
    if (this.isOpen(this.navigationButtonTarget)) {
      this.hidePanel(this.navigationButtonTarget, this.navigationMenuTarget)
      return
    }

    this.hidePanel(this.searchButtonTarget, this.searchMenuTarget)
    this.showPanel(this.navigationButtonTarget, this.navigationMenuTarget)
  }

  toggleSearch () {
    if (this.isOpen(this.searchButtonTarget)) {
      this.hidePanel(this.searchButtonTarget, this.searchMenuTarget)
      return
    }

    this.hidePanel(this.navigationButtonTarget, this.navigationMenuTarget)
    this.showPanel(this.searchButtonTarget, this.searchMenuTarget)
  }

  closePanels () {
    this.hidePanel(this.navigationButtonTarget, this.navigationMenuTarget)
    this.hidePanel(this.searchButtonTarget, this.searchMenuTarget)
  }

  handleKeydown (event) {
    if (event.key !== "Escape") {
      return
    }

    this.closePanels()
  }

  hidePanel (button, panel) {
    button.setAttribute("aria-expanded", "false")
    button.classList.remove("gem-c-layout-super-navigation-header__open-button")
    panel.hidden = true
    this.setButtonLabel(button, "show")
  }

  showPanel (button, panel) {
    button.setAttribute("aria-expanded", "true")
    button.classList.add("gem-c-layout-super-navigation-header__open-button")
    panel.hidden = false
    this.setButtonLabel(button, "hide")
  }

  isOpen (button) {
    return button.getAttribute("aria-expanded") === "true"
  }

  setButtonLabel (button, state) {
    const label = button.dataset[`${state}Label`]

    if (label) {
      button.setAttribute("aria-label", label)
    }
  }
}
