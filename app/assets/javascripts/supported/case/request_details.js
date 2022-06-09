window.addEventListener("load", () => {
  const querySelect = document.getElementById("select_request_details_query_id");

  if (querySelect.options[querySelect.selectedIndex].text != 'Other') {
    changeOtherQueryTextState("hidden")
  }

  querySelect.addEventListener("change", toggleQueryOtherBoxVisibility);

  const categorySelect = document.getElementById("select_request_details_category_id");

  if (categorySelect.options[categorySelect.selectedIndex].text != "Other") {
    changeOtherCategoryTextState("hidden")
  }
  categorySelect.addEventListener("change", toggleCategoryOtherBoxVisibility);

  const requestTypeOptions = document.querySelectorAll(".request_type_option")

  requestTypeOptions.forEach(option => {option.addEventListener("click", removeValuesOnSelect)});
});

function removeValuesOnSelect() {

  // true is procurement (has categories), false is non-procurement (has queries)
  if(this.value == "true") {
    const querySelect = document.getElementById("select_request_details_query_id");
    const otherQueryText = document.getElementById("request_details_other_query_text");
    changeOtherQueryTextState("hidden")

    querySelect.value = '';
    otherQueryText.value = '';
  } else {
    const otherCategoryText = document.getElementById("request_details_other_category_text");
    const categorySelect = document.getElementById("select_request_details_category_id");
    changeOtherCategoryTextState("hidden")

    otherCategoryText.value = '';
    categorySelect.value = '';
  }
}

function changeCategorySelectState(state) {
  const categorySelect = document.getElementById("select_request_details_category_id");

  if (state == "hidden") {
    categorySelect.selectedIndex = 0;
  }
}

function changeQuerySelectState(state) {
  const querySelect = document.getElementById("select_request_details_query_id");

  if (state == "hidden") {
    querySelect.selectedIndex = 0;
  }
}

function changeOtherCategoryTextState(state) {
  const otherCategoryText = document.getElementById("request_details_other_category_text");

  if (state == "hidden") {
    otherCategoryText.value = '';
    otherCategoryText.classList.add("govuk-!-display-none");
    otherCategoryText.parentNode.childNodes[0].classList.add("govuk-!-display-none");

  } else if (state == "visible") {
    otherCategoryText.classList.remove("govuk-!-display-none");
    otherCategoryText.parentNode.childNodes[0].classList.remove("govuk-!-display-none");
  }
}

function changeOtherQueryTextState(state) {
  const otherQueryText = document.getElementById("request_details_other_query_text");

  if (state == "hidden") {
    otherQueryText.value = '';
    otherQueryText.classList.add("govuk-!-display-none");
    otherQueryText.parentNode.childNodes[0].classList.add("govuk-!-display-none");

  } else if (state == "visible") {
    otherQueryText.classList.remove("govuk-!-display-none");
    otherQueryText.parentNode.childNodes[0].classList.remove("govuk-!-display-none");
  }
}

function toggleQueryOtherBoxVisibility() {
  if (this.options[this.selectedIndex].text == 'Other') {
    changeOtherQueryTextState("visible");
  } else {
    changeOtherQueryTextState("hidden")
  }
}

function toggleCategoryOtherBoxVisibility() {
  if (this.options[this.selectedIndex].text == 'Other') {
    changeOtherCategoryTextState("visible");
  } else {
    changeOtherCategoryTextState("hidden")
  }
}
