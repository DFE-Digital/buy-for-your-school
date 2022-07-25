(() => {

  const initializeHider = (button) => {
    button.addEventListener("click", (e) => {
      const { hide: targetSelector } = e.target.dataset;
      const results = document.querySelectorAll(targetSelector);
      results.forEach(result => result.setAttribute("hidden", true));
    });
  }

  document.addEventListener('DOMContentLoaded', () => {
    const elements = document.querySelectorAll('[data-hide]');
    elements.forEach(initializeHider);
  });

})();
