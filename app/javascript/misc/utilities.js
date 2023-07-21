export const display = (element, isVisible) => {
  element.classList.remove("govuk-!-display-none");

  if (!isVisible)
    element.classList.add("govuk-!-display-none");
}

export const enable = (element, isEnabled) => {
  element.removeAttribute("disabled");

  if (!isEnabled)
    element.setAttribute("disabled", true);
}
