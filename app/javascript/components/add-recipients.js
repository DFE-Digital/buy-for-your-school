function getCollectionValues(collectionName) {
  const collection = document.getElementsByName(collectionName)[0];
  return collection.value ? JSON.parse(collection.value) : [];
}

function removeRecipient(value, collectionName) {
  const collection = document.getElementsByName(collectionName)[0];
  const collectionValues = getCollectionValues(collectionName);
  collection.value = JSON.stringify(collectionValues.filter(v => v !== value));
}

function createRemoveLink(tableId, inputValue, collectionName) {
  const removeLink = document.createElement("a");
  removeLink.classList.add("govuk-link", "govuk-link--no-visited-state");
  removeLink.href = "#";
  const removeLabel = document.createTextNode("Remove");
  removeLink.appendChild(removeLabel);
  removeLink.addEventListener("click", e => {
    e.preventDefault();
    removeRecipient(inputValue, collectionName);
    buildTable(tableId, collectionName);
  });

  return removeLink;
}

function createRecipientRow(tableId, label, value, collectionName) {
  const recipientRow = document.createElement("tr");
  recipientRow.classList.add("govuk-table__row");

  const labelTh = document.createElement("th");
  labelTh.classList.add("govuk-table__header");
  labelTh.scope = "row";
  labelTh.appendChild(document.createTextNode(label));

  const recipientTd = document.createElement("td");
  recipientTd.classList.add("govuk-table__cell");
  const recipientEmail = document.createTextNode(value);
  recipientTd.appendChild(recipientEmail);

  const recipientRemoveTd = document.createElement("td");
  recipientRemoveTd.classList.add("govuk-table__cell", "govuk-table__cell--numeric");
  recipientRemoveTd.appendChild(createRemoveLink(tableId, value, collectionName));

  recipientRow.appendChild(labelTh);
  recipientRow.appendChild(recipientTd);
  recipientRow.appendChild(recipientRemoveTd);

  return recipientRow;
}

function showTables(inputFieldName) {
  const inputField = document.getElementsByName(inputFieldName)[0];
  buildTable(inputField.dataset.table, inputField.dataset.collection);
}

function buildTable(tableId, collectionName) {
  const table = document.getElementById(tableId);
  const tableBody = table.tBodies[0];
  tableBody.replaceChildren();
  const rowLabel = table.dataset.rowLabel;

  const collection = getCollectionValues(collectionName);
  table.hidden = collection.length == 0 ? true : false;
  collection.forEach(r => tableBody.appendChild(createRecipientRow(tableId, rowLabel, r, collectionName)));
}

function addRecipient(inputFieldName) {
  const inputField = document.getElementsByName(inputFieldName)[0];
  const collection = document.getElementsByName(inputField.dataset.collection)[0];
  var collectionValues = collection.value ? JSON.parse(collection.value) : [];
  const inputValue = inputField.value;
  collectionValues.push(inputValue);
  collectionValues = [...new Set(collectionValues)].filter(Boolean) // ensure values are unique and non-null
  collection.value = JSON.stringify(collectionValues);
  buildTable(inputField.dataset.table, inputField.dataset.collection);
  inputField.value = "";
}

function getRecipientsButtons() {
  return document.querySelectorAll('[data-component="add-recipients"]');
}

function pressEnterInInputBoxToAddRecipient(addButton) {
  const inputField = document.querySelector(`input[name="${addButton.dataset.inputField}"]`);
  inputField.addEventListener("keypress", (e) => {
    if (e.key == "Enter") {
      e.preventDefault();
      addButton.click();
    }
  })
}

function clickAddButtonToAddRecipient(addButton) {
  addButton.addEventListener("click", () => addRecipient(addButton.dataset.inputField));
}

const addRecipients = () => {
  getRecipientsButtons().forEach(b => {
    showTables(b.dataset.inputField);
    pressEnterInInputBoxToAddRecipient(b);
    clickAddButtonToAddRecipient(b);
  });
};

window.addEventListener("DOMContentLoaded", addRecipients);
window.addEventListener("turbo:frame-load", addRecipients);
