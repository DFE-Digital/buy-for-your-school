/*
  Reveal the category selection dropdown
*/

function changeCategorySelectState(state) {
  const categorySelect = document.getElementById("create-case-form-category-id-field");
  if (state == "hidden") {
    categorySelect.parentNode.classList.add("govuk-!-display-none")
  } else if (state == "visible") {
    categorySelect.parentNode.classList.remove("govuk-!-display-none")
  }
}

window.addEventListener("load", () => {
  const requestTypeYes = document.querySelectorAll("input[value=true]")[0];
  const requestTypeNo = document.querySelectorAll("input[value=false]")[0];

  requestTypeYes.addEventListener("change", () => {
    if (requestTypeYes.checked) {
      changeCategorySelectState("visible");
    }
  });

  requestTypeNo.addEventListener("change", () => {
    if (requestTypeNo.checked) {
      changeCategorySelectState("hidden");
    }
  });
});

