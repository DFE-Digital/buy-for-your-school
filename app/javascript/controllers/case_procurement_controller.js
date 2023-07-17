import { Controller } from "@hotwired/stimulus"
import { display } from "../misc/utilities"

// Connects to data-controller="case-procurement"
export default class extends Controller {
  static targets = ["procurementRadio", "nonProcurementRadio", "procurementStage", "procurementStageWrapper"];

  connect() {
    if (this.procurementRadioTarget.checked) {
      this.showProcurementStage();
    } else {
      this.hideProcurementStage();
    }
  }

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
        this.procurementStageTarget.removeAttribute("disabled");
        break;
      default:
        this.procurementStageTarget.setAttribute("disabled", true);
        this.procurementStageTarget.selectedIndex = 0;
    }
  }

  submit() {
    this.procurementStageTarget.removeAttribute("disabled");
  }
}
