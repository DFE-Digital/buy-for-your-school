/*
  Deselect school_urn radio buttons if a group_uid is selected and vice versa
*/

function uncheck(radioButtons) {
  radioButtons.forEach(r => r.checked = false);
}

window.addEventListener("load", () => {
  const schoolRadioButtons = document.querySelectorAll("input[name='framework_support_form[school_urn]'][type=radio]");
  const groupRadioButtons = document.querySelectorAll("input[name='framework_support_form[group_uid]'][type=radio]");
  const schoolField = document.querySelector("input[name='framework_support_form[school_urn]'][type=hidden]");
  const groupField = document.querySelector("input[name='framework_support_form[group_uid]'][type=hidden]");

  schoolRadioButtons.forEach(r => {
    r.addEventListener("change", () => {
      if (r.checked) {
        uncheck(groupRadioButtons);
        groupField.value = null;
      }
    });
  });

  groupRadioButtons.forEach(r => {
    r.addEventListener("change", () => {
      if (r.checked) {
        uncheck(schoolRadioButtons);
        schoolField.value = null;
      }
    });
  });
});
