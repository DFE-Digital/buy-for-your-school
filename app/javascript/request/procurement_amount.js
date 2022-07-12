/*
  Manage the procurement amount fields in the support/FaF request form
*/

import { getFormId, getFormIdUnderscore } from "./common.js";

window.addEventListener("load", () => {
  const formId = getFormId();
  const formIdUnderscore = getFormIdUnderscore();

  const procurementChoiceYesRadioButton = document.getElementById(`${formId}-procurement-choice-yes-field`);
  const procurementChoiceNoRadioButton = document.getElementById(`${formId}-procurement-choice-no-field`);
  const procurementChoiceNotProcurementRadioButton = document.getElementById(`${formId}-procurement-choice-not-about-procurement-field`);
  const procurementAmountInput = document.getElementsByName(`${formIdUnderscore}[procurement_amount]`)[0];
  const aboutProcurementInput = document.getElementsByName(`${formIdUnderscore}[about_procurement]`)[0];
  const procurementChoice = document.querySelector(`input[name='${formIdUnderscore}[procurement_choice]']:checked`);
  const procurementChoiceValue = procurementChoice && procurementChoice.value;

  // set the radio button based on existing values
  if (procurementChoiceValue == undefined) {
    if (procurementAmountInput.value != "") {
      procurementChoiceYesRadioButton.checked = true;
    } else if (aboutProcurementInput.value === "false") {
      procurementChoiceNotProcurementRadioButton.checked = true;
    } else if (aboutProcurementInput.value === "true") {
      procurementChoiceNoRadioButton.checked = true;
    }
  }

  // event handlers for setting the field value based on checked radio button
  procurementChoiceNoRadioButton.addEventListener("change", () => {
    if (procurementChoiceNoRadioButton.checked) {
      procurementAmountInput.value = null;
    }
  });

  procurementChoiceNotProcurementRadioButton.addEventListener("change", () => {
    if (procurementChoiceNotProcurementRadioButton.checked) {
      procurementAmountInput.value = null;
    }
  });
});
