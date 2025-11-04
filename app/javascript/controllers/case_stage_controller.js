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
    const formObject = this.procurementStageWrapperTarget.closest("form");
    let procurement;
    let procurementCategory;
    let nonProcurement;
    let nonProcurementCategory;
    let energyCategory;
    let otherCategory;
    let procurementText;
    let procurementLabel;
    let otherCategoryText;
    let otherCategoryLabel;
    if (formObject) {
      procurement = formObject.querySelector("#case-summary-request-type-true-field");
      procurementCategory = formObject.querySelector("#case-summary-request-type-true-conditional");
      nonProcurement = formObject.querySelector("#case-summary-request-type-field");
      nonProcurementCategory = formObject.querySelector("#case-summary-request-type-conditional");
      energyCategory = formObject.querySelector("#select_request_details_category_id");
      otherCategory = formObject.querySelector("#select_request_details_query_id");
      procurementText = formObject.querySelector("#request_details_other_category_text");
      procurementLabel = formObject.querySelector('label[for="request_details_other_category_text"]');
      otherCategoryText = formObject.querySelector("#request_details_other_query_text");
      otherCategoryLabel = formObject.querySelector('label[for="request_details_other_query_text"]');
    }

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

    // Helper function to update categories
    const updateCategories = (energyText, otherText) => {
      const energyOption = Array.from(energyCategory.options).find(option => option.text === energyText);
      if (energyOption) energyCategory.value = energyOption.value;

      const otherOption = Array.from(otherCategory.options).find(option => option.text === otherText);
      if (otherOption) otherCategory.value = otherOption.value;

      procurementCategory.classList = "govuk-radios__conditional";
      nonProcurementCategory.classList = "govuk-radios__conditional govuk-radios__conditional--hidden";
      procurementText.classList = "govuk-input govuk-!-display-none";
      procurementLabel.classList = "govuk-label govuk-!-display-none";
      otherCategoryText.classList = "govuk-input govuk-!-display-none";
      otherCategoryLabel.classList = "govuk-label govuk-!-display-none";
    };

    if (procurement) {
      if (supportLevel === "L6") {
        nonProcurement.checked = false;
        procurement.checked = true;
        procurement.dispatchEvent(new Event("change"));
        updateCategories("DfE Energy for Schools service", "Please select");
      } else {
        const energyCategorySelected = energyCategory.options[energyCategory.selectedIndex].text;
        if (!(energyCategorySelected === "DfE Energy for Schools service" && procurement.checked)) return false;
    
        nonProcurement.checked = false;
        procurement.checked = true;
        procurement.dispatchEvent(new Event("change"));
        updateCategories("Please select", "Please select");
      }
    }
  }

  enableProcurementStageElement() {
    enable(this.procurementStageTarget, true);
  }
}
