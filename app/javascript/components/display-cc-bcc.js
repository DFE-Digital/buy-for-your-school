function toggleCcBccDisplay(button) {
  const ccBccInputs = document.getElementById("cc-and-bcc");
  ccBccInputs.hidden = !ccBccInputs.hidden;
  button.innerText = ccBccInputs.hidden === true ? "Show CC / BCC" : "Hide CC / BCC";
}

function getDisplayButtons() {
  return document.querySelectorAll('[data-component="display-cc-bcc"]');
}

const displayCcBcc = () => {
  getDisplayButtons().forEach(b => {
    b.addEventListener("click", () => {
      toggleCcBccDisplay(b);
    });
  });
};

window.addEventListener("DOMContentLoaded", displayCcBcc);
window.addEventListener("turbo:frame-load", displayCcBcc);
