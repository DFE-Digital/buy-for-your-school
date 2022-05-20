/*
  Common methods for request forms
*/

export function getFormId() {
  return document.getElementsByTagName("form")[0].id;
}

export function getFormIdUnderscore() {
  return getFormId().replace("-", "_");
}
