/*
  Reveal the category selection dropdown
*/

function changeCategorySelectState(state) {
  const categorySelect = document.querySelectorAll("select[name='create_case_form[category_id]']")[0];

  if (state == "hidden") {
    categorySelect.selectedIndex = 0;
    categorySelect.parentNode.classList.add("govuk-!-display-none");

  } else if (state == "visible") {
    categorySelect.parentNode.classList.remove("govuk-!-display-none");
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

