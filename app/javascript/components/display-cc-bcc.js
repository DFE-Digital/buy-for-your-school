function toggleCcBccDisplay(button) {
  const ccBccInputs = document.getElementById("cc-and-bcc");
  ccBccInputs.hidden = !ccBccInputs.hidden;
  button.innerText = ccBccInputs.hidden === true ? "Show CC / BCC" : "Hide CC / BCC";
}

function getDisplayButtons() {
  return document.querySelectorAll('[data-component="display-cc-bcc"]');
}

(() => {
  window.addEventListener("DOMContentLoaded", () => {
    getDisplayButtons().forEach(b => {
      b.addEventListener("click", () => {
        toggleCcBccDisplay(b);
      });
    });
  });
})();
