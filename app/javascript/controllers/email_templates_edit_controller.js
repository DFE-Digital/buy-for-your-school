import { Controller } from "@hotwired/stimulus"
import { display } from "../misc/utilities"

// Connects to data-controller="email-templates-edit"
export default class extends Controller {
  static targets = [
    "subgroupWrapper",
    "subgroupSelect",
    "variableWarning",
    "stageSelect"
  ];
  static values = { subgroupUrl: String };

  populateSubgroups(e) {
    const groupId = e.target.value;

    const groupText = e.target.options[e.target.selectedIndex].text;
    const stageOptions = this.stageToOptions(groupText, "Select stage");
    this.stageSelectTarget.replaceChildren(...stageOptions);
    
    if (!groupId) {
      this.clearSubgroups();
      return;
    }

    fetch(this.subgroupSource(groupId), { method: "get", headers: { "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]')?.content }})
      .then(res => res.json())
      .then(data => {
        if (data.length > 0) {
          const options = this.groupsToOptions(data, "Select subgroup");
          this.subgroupSelectTarget.replaceChildren(...options);
          display(this.subgroupWrapperTarget, true);
        } else {
          this.clearSubgroups();
        }
      })
      .catch(err => console.log(err));
  }

  subgroupSource(groupId) {
    return `${this.subgroupUrlValue}/${groupId}`;
  }

  groupsToOptions(groups, selectText) {
    const options = groups.map(group => {
      const option = document.createElement("option");
      option.setAttribute("value", group.id);
      option.textContent = group.title;
      return option;
    });
    const selectOption = document.createElement("option");
    selectOption.textContent = selectText;
    selectOption.setAttribute("value", "");
    options.unshift(selectOption);

    return options;
  }

  clearSubgroups() {
    this.subgroupSelectTarget.replaceChildren();
    display(this.subgroupWrapperTarget, false);
  }

  displayVariablesWarning(e) {
    const body = tinymce.activeEditor.getContent();
    display(this.variableWarningTarget, body.indexOf("{{caseworker_full_name}}") > -1);
  }

  stageToOptions(groupText, selectText) {
    const defaultStages = [
      { id: 0, title: "Stage 0" },
      { id: 1, title: "Stage 1" },
      { id: 2, title: "Stage 2" },
      { id: 3, title: "Stage 3" },
      { id: 4, title: "Stage 4" }
    ]

    const cecStages = [
      { id: 5, title: "Enquiry" },
      { id: 6, title: "Onboarding form" },
      { id: 7, title: "Form review" },
      { id: 8, title: "With supplier" },
      { id: 9, title: "Objection" },
      { id: 10, title: "Awaiting contract start" },
      { id: 11, title: "Interim rate customer" },
      { id: 12, title: "V30 Rate Customer" }
    ]

    const allStages = [...defaultStages, ...cecStages];

    let stageOptions;
    if (groupText == 'CEC') {
      stageOptions = cecStages;
    } else if (groupText == 'System') {
      stageOptions = allStages;
    } else {
      stageOptions = defaultStages;
    }
    const options = stageOptions.map(stage => {
      const option = document.createElement("option");
      option.setAttribute("value", stage.id);
      option.textContent = stage.title;
      return option;
    });
    const selectOption = document.createElement("option");
    selectOption.textContent = selectText;
    selectOption.setAttribute("value", "");
    options.unshift(selectOption);

    return options;
  }
}
