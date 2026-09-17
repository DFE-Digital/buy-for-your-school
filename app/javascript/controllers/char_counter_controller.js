// app/javascript/controllers/char_counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "label"]
  static values = { limit: Number }

  connect() {
    this.update()
  }

  update() {
    const remaining = this.limitValue - this.inputTarget.value.length
    this.labelTarget.textContent = `${remaining} characters remaining`
  }
}