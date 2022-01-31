/*
  Change where the form submits
  1. How can we help page
  2. Select your school page
*/

function changeFormAction(path) {
  const form = document.getElementsByTagName("form")[0];
  form.action = path;
}

window.addEventListener("load", () => {
  const continueRadioButton = document.getElementById("framework-support-form-choice-yes-field");
  const goBackRadioButton = document.getElementById("framework-support-form-choice-no-field");

  continueRadioButton.addEventListener("change", () => {
    if (continueRadioButton.checked) {
      changeFormAction("/procurement-support");
    }
  });

  goBackRadioButton.addEventListener("change", () => {
    if (goBackRadioButton.checked) {
      const backLink = document.getElementsByClassName("govuk-back-link")[0].getAttribute("href");
      changeFormAction(backLink);
    }
  });
});
