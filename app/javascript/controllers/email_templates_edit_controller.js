import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="email-templates-edit"
export default class extends Controller {
  static targets = [ "subgroupWrapper", "subgroupSelect", "variableWarning" ];
  static values = { subgroupUrl: String };

  populateSubgroups(e) {
    const groupId = e.target.value;
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
          this.subgroupWrapperTarget.classList.remove("govuk-!-display-none");
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
    this.subgroupWrapperTarget.classList.add("govuk-!-display-none");
  }

  showVariableWarning(show) {
    if (show) {
      this.variableWarningTarget.classList.remove("govuk-!-display-none");
    } else {
      this.variableWarningTarget.classList.add("govuk-!-display-none");
    }
  }

  findVariables(e) {
    const body = tinymce.activeEditor.getContent();
    this.showVariableWarning(body.indexOf("{{caseworker_full_name}}") > -1);
  }
}
