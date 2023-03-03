const viewHiddenResponses = () => {
  const viewHiddenResponsesInstances = document.querySelectorAll('[data-component="view-hidden-responses"]');

  viewHiddenResponsesInstances.forEach(element => {
    const button = element.querySelector('.show-action button');
    const responses = element.querySelector('.hidden-responses');

    button.addEventListener("click", (e) => {
      button.parentElement.remove();
      responses.classList.remove("govuk-!-display-none");
    });
  });
};

window.addEventListener("DOMContentLoaded", viewHiddenResponses);
window.addEventListener("turbo:frame-load", viewHiddenResponses);
