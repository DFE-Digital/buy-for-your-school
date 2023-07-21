import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="case-summary"
export default class extends Controller {
  static outlets = ["request-type", "case-stage"];

  caseStageOutletConnected(outlet) {
    if (this.hasRequestTypeOutlet) {
      if (this.requestTypeOutlet.isProcurementRadioChecked()) {
        outlet.showProcurementStage();
      } else {
        outlet.hideProcurementStage();
      }
    }
  }

  requestTypeOutletConnected(outlet) {
    outlet.setupOnProcurementSelected(this.onProcurementSelected.bind(this));
    outlet.setupOnNonProcurementSelected(this.onNonProcurementSelected.bind(this));
  }

  onProcurementSelected() {
    this.caseStageOutlet.showProcurementStage();
  }

  onNonProcurementSelected() {
    this.caseStageOutlet.hideProcurementStage();
  }

  submit() {
    this.caseStageOutlet.enableProcurementStageElement();
  }
}
