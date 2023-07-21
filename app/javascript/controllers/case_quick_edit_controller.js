import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="case-quick-edit"
export default class extends Controller {
  static values = { showProcurementStage: Boolean };
  static outlets = ["case-stage"];

  caseStageOutletConnected(outlet) {
    if (this.showProcurementStageValue) {
      outlet.showProcurementStage();
    } else {
      outlet.hideProcurementStage();
    }
  }

  submit() {
    this.caseStageOutlet.enableProcurementStageElement();
  }
}
