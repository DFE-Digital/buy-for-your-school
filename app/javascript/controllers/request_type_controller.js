import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="request-type"
export default class extends Controller {
  static targets = ["procurementRadio"];

  initialize() {
    this.onProcurementSelectedCallback = () => {};
    this.onNonProcurementSelectedCallback = () => {};
  }

  setupOnProcurementSelected(callback) {
    this.onProcurementSelectedCallback = callback;
  }

  setupOnNonProcurementSelected(callback) {
    this.onNonProcurementSelectedCallback = callback;
  }

  procurementSelected(event) {
    this.onProcurementSelectedCallback(event);
  }

  nonProcurementSelected(event) {
    this.onNonProcurementSelectedCallback(event);
  }

  isProcurementRadioChecked() {
    return this.procurementRadioTarget.checked;
  }
}
