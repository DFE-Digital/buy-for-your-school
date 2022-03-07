/*
  Toggle hiding / showing of panels (e.g. filter panels)
*/

function toggleElementDisplay(element) {
  const targetElement = document.getElementById(element);

  if (targetElement.className === "govuk-!-display-none") {
    targetElement.className = "govuk-!-display-block show";
  } else {
    targetElement.className = "govuk-!-display-none hide";
  }
}

window.addEventListener("load", () => {
  const panelToggleVisibility = document.querySelectorAll('[data-component="toggle-panel-visibility"]');

  panelToggleVisibility.forEach(button => {
    button.addEventListener("click", (e) => {
      e.preventDefault();
      toggleElementDisplay(button.dataset.panel);
    });
  });
});
