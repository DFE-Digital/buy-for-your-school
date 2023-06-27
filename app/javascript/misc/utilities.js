export const display = (element, isVisible) => {
  element.classList.remove("govuk-!-display-none");

  if (!isVisible)
      element.classList.add("govuk-!-display-none");
}
