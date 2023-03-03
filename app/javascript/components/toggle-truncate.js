const toggleTruncate = () => {
  const toggleTruncateInstances = document.querySelectorAll('[data-component="toggle-truncate"]');

  toggleTruncateInstances.forEach(element => {
    const truncatePreview = element.querySelector('.truncated');
    const fullView = element.querySelector('.full-view');

    element.addEventListener("click", (e) => {
      truncatePreview.remove();
      fullView.classList.remove("govuk-!-display-none");
      element.classList.remove('truncated-view')
    });
  });
};

window.addEventListener("DOMContentLoaded", toggleTruncate);
window.addEventListener("turbo:frame-load", toggleTruncate);
