/*
  Supported: Display email attachments
*/

function removeAttachment(attachment) {
  const dataTransfer = new DataTransfer();
  const fileInput = getFileInput();
  const files = Array.from(fileInput.files);
  const index = files.indexOf(attachment);
  files.splice(index, 1);
  files.forEach(f => dataTransfer.items.add(f));
  fileInput.files = dataTransfer.files;
  fileInput.dispatchEvent(new Event("change"));
}

function createRemoveLink(attachment) {
  const removeLink = document.createElement("a");
  removeLink.classList.add("govuk-link", "govuk-link--no-visited-state");
  removeLink.href = "#";
  const removeLabel = document.createTextNode("Remove");
  removeLink.appendChild(removeLabel);
  removeLink.addEventListener("click", () => removeAttachment(attachment));

  return removeLink;
}

function createAttachmentRow(attachment) {
  const attachmentRow = document.createElement("tr");
  attachmentRow.classList.add("govuk-table__row");

  const attachmentTh = document.createElement("th");
  attachmentTh.classList.add("govuk-table__header", "govuk-!-font-weight-regular");
  attachmentTh.scope = "row";
  const attachmentName = document.createTextNode(attachment.name);
  attachmentTh.appendChild(attachmentName);

  const attachmentBlankTd = document.createElement("td");
  attachmentBlankTd.classList.add("govuk-table__cell");

  const attachmentRemoveTd = document.createElement("td");
  attachmentRemoveTd.classList.add("govuk-table__cell", "govuk-table__cell--numeric");

  attachmentRemoveTd.appendChild(createRemoveLink(attachment));

  attachmentRow.appendChild(attachmentTh);
  attachmentRow.appendChild(attachmentBlankTd);
  attachmentRow.appendChild(attachmentRemoveTd);

  return attachmentRow;
}

function displayEmailAttachments(attachments) {
  const attachmentBox = document.getElementById("added_attachments");
  attachmentBox.hidden = attachments.length == 0 ? true : false;

  const attachmentTable = document.getElementById("added_attachments_table");
  const tableBody = attachmentTable.tBodies[0];
  tableBody.replaceChildren();

  Array.from(attachments).forEach(a => tableBody.appendChild(createAttachmentRow(a)));
}

function getFileInput() {
  // the input ID changes if there's been a validation error
  return document.getElementById("message-reply-form-attachments-field") || document.getElementById("message-reply-form-attachments-field-error");
}

window.addEventListener("load", () => {
  const fileInput = getFileInput();
  fileInput.addEventListener("change", () => {
    displayEmailAttachments(fileInput.files);
  });
});
