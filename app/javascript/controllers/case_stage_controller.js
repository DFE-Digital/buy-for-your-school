import { Controller } from "@hotwired/stimulus"
import { display, enable } from "../misc/utilities"

// Connects to data-controller="case-stage"
export default class extends Controller {
  static targets = ["procurementStage", "procurementStageWrapper"];

  showProcurementStage() {
    if (!this.procurementStageTarget.value) {
      this.procurementStageTarget.selectedIndex = 0;
    }
    display(this.procurementStageWrapperTarget, true);
  }

  hideProcurementStage() {
    display(this.procurementStageWrapperTarget, false);
    this.procurementStageTarget.value = null;
  }

  toggleProcurementStageEnabled(e) {
    const supportLevel = e.target.value;
    switch (supportLevel) {
      case "L4":
      case "L5":
      case "L6":
      case "L7":
        enable(this.procurementStageTarget, true);
        break;
      default:
        enable(this.procurementStageTarget, false);
        this.procurementStageTarget.selectedIndex = 0;
    }
  }

  enableProcurementStageElement() {
    enable(this.procurementStageTarget, true);
  }
}
