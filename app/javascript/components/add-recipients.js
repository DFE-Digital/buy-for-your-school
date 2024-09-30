function getCollectionValues(collectionName) {
  const collection = document.getElementsByName(collectionName)[0];
  return collection.value ? JSON.parse(collection.value) : [];
}

function removeRecipient(value, collectionName) {
  const collection = document.getElementsByName(collectionName)[0];
  const collectionValues = getCollectionValues(collectionName);
  collection.value = JSON.stringify(
    collectionValues.filter(v => JSON.stringify(v) !== JSON.stringify(value))
  );
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

  const recipientEmailTd = document.createElement("td");
  recipientEmailTd.classList.add("govuk-table__cell");
  const recipientEmail = document.createTextNode(value[0]);
  recipientEmailTd.appendChild(recipientEmail);

  const recipientRoleTd = document.createElement("td");
  recipientRoleTd.classList.add("govuk-table__cell", "recipient-spacing");
  const rolevalue = value[1] && value[1].length > 0 
  ? (value[1][1] && value[1][1].length > 1) 
      ? [capitalizeFirstLetter(value[1][0]), capitalizeFirstLetter(value[1][1])] 
      : value[1][0].length > 1
        ? [capitalizeFirstLetter(value[1][0])] // Handle the single element correctly here
        : [capitalizeFirstLetter(value[1])]
  : "";  const recipientRole = document.createTextNode(rolevalue);
  recipientRoleTd.appendChild(recipientRole);

  const recipientRemoveTd = document.createElement("td");
  recipientRemoveTd.classList.add("govuk-table__cell", "govuk-table__cell--numeric");
  recipientRemoveTd.appendChild(createRemoveLink(tableId, value, collectionName));

  recipientRow.appendChild(labelTh);
  recipientRow.appendChild(recipientEmailTd);
  recipientRow.appendChild(recipientRoleTd);
  recipientRow.appendChild(recipientRemoveTd);

  return recipientRow;
}

function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
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
  const newRecipient = [inputValue, []];
  collectionValues.push(newRecipient);
  collectionValues = collectionValues.filter((item, index, self) => 
    item[0] && self.findIndex(r => r[0] === item[0]) === index
  );
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
