/*
  DSI USERS ONLY

  toggle "group" form field when an organisation is selected
*/


window.addEventListener("load", () => {

  const hiddenGroupField = document.querySelector("input[name='framework_support_form[group]'][type=hidden]");
  const orgRadioButtons = document.querySelectorAll("input[name='framework_support_form[organisation_id]'][type=radio]");

  orgRadioButtons.forEach(r => {
    r.addEventListener("change", () => {
      if (r.checked) {
        hiddenGroupField.value = r.getAttribute("group");
      }
    });
  });

});
