/*
  Supported: Display email attachments
*/


function removeAttachment(attachment, fileInput) {
  const dataTransfer = new DataTransfer();
  const files = Array.from(fileInput.files);
  const index = files.indexOf(attachment);
  files.splice(index, 1);
  files.forEach(f => dataTransfer.items.add(f));
  fileInput.files = dataTransfer.files;
  fileInput.dispatchEvent(new Event("change"));
}

function createRemoveLink(attachment, fileInput) {
  const removeLink = document.createElement("a");
  removeLink.classList.add("govuk-link", "govuk-link--no-visited-state");
  removeLink.href = "#";
  const removeLabel = document.createTextNode("Remove");
  removeLink.appendChild(removeLabel);
  removeLink.addEventListener("click", e => {
    e.preventDefault();
    removeAttachment(attachment, fileInput)
  });

  return removeLink;
}

function createAttachmentRow(attachment, fileInput) {
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

  attachmentRemoveTd.appendChild(createRemoveLink(attachment, fileInput));

  attachmentRow.appendChild(attachmentTh);
  attachmentRow.appendChild(attachmentBlankTd);
  attachmentRow.appendChild(attachmentRemoveTd);

  return attachmentRow;
}

function getFileInputs() {
  return document.querySelectorAll('[data-component="display-attachments"]');
}

function displayEmailAttachments(fileInput) {
  const attachments = fileInput.files;
  const target = `#${fileInput.dataset.displayAttachmentsId}`;

  const attachmentBox = document.querySelector(target);
  attachmentBox.hidden = attachments.length == 0 ? true : false;

  const attachmentTable = document.querySelector(`${target} .added_attachments_table`);
  const tableBody = attachmentTable.tBodies[0];
  tableBody.replaceChildren();

  Array.from(attachments).forEach(a => tableBody.appendChild(createAttachmentRow(a, fileInput)));
}

const displayAttachments = () => {
  getFileInputs().forEach(function (el, i) {
    el.addEventListener("change", function () {
      displayEmailAttachments(el)
    });
  });
};

window.addEventListener("DOMContentLoaded", displayAttachments);
window.addEventListener("turbo:frame-load", displayAttachments);
