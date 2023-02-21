/*
  Toggle hiding / showing of panels (e.g. filter panels)
*/

function toggleElementDisplay(element) {
  const targetElement = document.getElementById(element);

  if (targetElement.classList.contains("govuk-!-display-none")) {
    targetElement.classList.add("govuk-!-display-block");
    targetElement.classList.remove("govuk-!-display-none");
  } else {
    targetElement.classList.remove("govuk-!-display-block");
    targetElement.classList.add("govuk-!-display-none");
  }
}

const initializeAllTogglers = (rootElement) => {
  const panelToggleVisibility = rootElement.querySelectorAll('[data-component="toggle-panel-visibility"]');

  panelToggleVisibility.forEach((button) => {
    button.addEventListener("click", (e) => {
      e.preventDefault();
      toggleElementDisplay(button.dataset.panel);
    });
  });
}

window.addEventListener("load", () => initializeAllTogglers(document));
window.addEventListener("turbo:frame-load", (event) => initializeAllTogglers(event.target));
