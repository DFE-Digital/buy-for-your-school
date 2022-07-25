(() => {

  const initialize = () => {
    const initializeElement = element => {
      element.onclick = () => window.close();
    }

    const elements = document.querySelectorAll('[data-close-tab-link]');
    elements.forEach(initializeElement);
  }

  document.addEventListener('DOMContentLoaded', initialize);

})();
