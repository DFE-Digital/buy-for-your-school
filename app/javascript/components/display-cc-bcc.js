function toggleCcDisplay(button) {
  const ccInputs = document.getElementById("cc");
  ccInputs.hidden = !ccInputs.hidden;
  button.innerText = ccInputs.hidden === true ? "Show CC" : "Hide CC";
}

function toggleBccDisplay(button) {
  const bccInputs = document.getElementById("bcc");
  bccInputs.hidden = !bccInputs.hidden;
  button.innerText = bccInputs.hidden === true ? "Show BCC" : "Hide BCC";
}

function getDisplayCcButtons() {
  return document.querySelectorAll('[data-component="display-cc"]');
}

function getDisplayBccButtons() {
  return document.querySelectorAll('[data-component="display-bcc"]');
}

const displayCcBcc = () => {
  getDisplayCcButtons().forEach(b => {
    b.addEventListener("click", () => toggleCcDisplay(b));
  });

  getDisplayBccButtons().forEach(b => {
    b.addEventListener("click", () => toggleBccDisplay(b));
  });
};

window.addEventListener("DOMContentLoaded", displayCcBcc);
window.addEventListener("turbo:frame-load", displayCcBcc);
