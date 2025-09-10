window.addEventListener("load", () => {
  // Query
  const querySelect = document.getElementById("select_request_details_query_id");
  querySelect.addEventListener("change", toggleQueryOtherBoxVisibility);
  toggleQueryOtherBoxVisibility.bind(querySelect)();

  // Category
  const categorySelect = document.getElementById("select_request_details_category_id");
  categorySelect.addEventListener("change", toggleCategoryOtherBoxVisibility);
  toggleCategoryOtherBoxVisibility.bind(categorySelect)();

  // Request type
  const requestTypeOptions = document.querySelectorAll(".request_type_option")
  requestTypeOptions.forEach(option => {option.addEventListener("click", removeValuesOnSelect)});

  // Energy: Category handling set to ‘Energy for schools service’
  categorySelect.addEventListener("change", handlingEnergyCategory);
  // Energy:: Request type handling set to ‘non-procurement’
  requestTypeOptions.forEach(option => {option.addEventListener("click", handlingEnergyRequestType)});
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
    const supportLevel6 = document.getElementById("case-summary-support-level-l6-field");
    changeOtherCategoryTextState("hidden")

    otherCategoryText.value = '';
    categorySelect.value = '';

    if (supportLevel6.checked) {
      document.getElementById("case-summary-support-level-l1-field").checked = true;
    }
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
  const otherOrChosen = this.options[this.selectedIndex].text.startsWith("Other")
  changeOtherCategoryTextState(otherOrChosen ? "visible" : "hidden")
}

function handlingEnergyCategory() {
  const energyCategory = this.options[this.selectedIndex].text == 'DfE Energy for Schools service'
  const caseLevel1 = document.querySelector("#case-summary-support-level-l1-field");
  const caseLevel6 = document.querySelector("#case-summary-support-level-l6-field");
  const procurementStage = document.querySelector("#case-summary-procurement-stage-id-field");

  if (energyCategory ) {
    const stageSelect = Array.from(procurementStage.options).find(option => option.text === "Enquiry");
    if (stageSelect) {
      procurementStage.value = stageSelect.value;
      procurementStage.dispatchEvent(new Event("change"))
    }
    
    caseLevel6.checked = true
    caseLevel6.dispatchEvent(new Event("change"));
  } else {
    if (!procurementStage.disabled) {
      procurementStage.selectedIndex = 0
      procurementStage.dispatchEvent(new Event("change"))
    }
    caseLevel6.checked = false
    caseLevel1.checked = true
    caseLevel1.dispatchEvent(new Event("change"));
  }
}

function handlingEnergyRequestType() {
  // If the case level is L6 or L7, reset it to L1
  const caseLevel = document.querySelector("input[name='case_summary[support_level]']:checked");

  if (caseLevel.value == "L6" || caseLevel.value == "L7") {
    const caseLevel1 = document.querySelector("input[name='case_summary[support_level]'][value='L1']");
    caseLevel1.checked = true;
    caseLevel1.dispatchEvent(new Event("change"));
  }

  // If stage is any value in stage 5 or 6, then set stage = ‘Need’
  const procurementStage = document.getElementById("case-summary-procurement-stage-id-field");
  const selectedStage = procurementStage.options[procurementStage.selectedIndex];
  const selectedStageGroup = selectedStage.closest("optgroup")?.getAttribute("label");

  if (selectedStageGroup == 'STAGE 5' || selectedStageGroup == 'STAGE 6') {
    procurementStage.selectedIndex = 0
    procurementStage.dispatchEvent(new Event("change"))
  }
}
