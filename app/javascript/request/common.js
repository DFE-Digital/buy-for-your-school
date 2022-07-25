/*
  Common methods for request forms
*/

function getFormId() {
  return document.querySelectorAll("[id$=support-form]")[0].id;
}

function getFormIdUnderscore() {
  return getFormId().replaceAll("-", "_");
}

export { getFormId, getFormIdUnderscore }
