function changeFormAction() {
  const form = document.getElementsByTagName("form")[0]
  form.action = "/auth/dfe"
}

window.addEventListener("load", () => {
  const dsiRadioButton = document.getElementById("faf-form-dsi-true-field")

  dsiRadioButton.addEventListener("change", () => {
    if (dsiRadioButton.checked) {
      changeFormAction()
    }
  })
})
