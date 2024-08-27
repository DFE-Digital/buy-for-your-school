import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status", "subCategory", "assignee", "stage", "level"]

  saveScrollPosition(event) {
    localStorage.setItem('scrollPosition', window.scrollY);

    this.constructor.targets.forEach(target => {
      if (this[`has${this.capitalize(target)}Target`]) {
        const content = this[`${target}Target`]?.querySelector('.expander__content');
        if (content) {
          localStorage.setItem(`${target}ScrollPosition`, content.scrollTop);
        }
      }
    });
  }
  
  connect() {
    setTimeout(() => {
      const savedScrollPosition = localStorage.getItem('scrollPosition');
      if (savedScrollPosition) {
        window.scrollTo(0, parseInt(savedScrollPosition, 10));
      }

      this.constructor.targets.forEach(target => {
        if (this[`has${this.capitalize(target)}Target`]) {
          const content = this[`${target}Target`]?.querySelector('.expander__content');
          const savedScrollPosition = localStorage.getItem(`${target}ScrollPosition`);
          if (content && savedScrollPosition) {
            content.scrollTo(0, parseInt(savedScrollPosition, 10));
          }
        }
      });
    }, 100); // 100ms delay to ensure DOM is fully loaded
  }

  capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }
}
