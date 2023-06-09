import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"

// Connects to data-controller="email-templates-edit"
export default class extends Controller {
  static targets = [
    "subgroupWrapper",
    "subgroupSelect",
    "variableWarning",
    "btnDisplayFileDialog",
    "attachmentList",
    "previewTemplate",
    "attachmentPreview",
    "attachmentsField",
    "removeAttachmentsField"
  ];
  static values = { subgroupUrl: String, attachmentListUrl: String };

  connect() {
    const previewTemplate = this.previewTemplateTarget.innerHTML;
    this.previewTemplateTarget.parentNode.removeChild(this.previewTemplateTarget);

    this.dropzone = new Dropzone(
      this.element,
      {
        previewTemplate: previewTemplate,
        previewsContainer: this.attachmentPreviewTarget,
        autoProcessQueue: false,
        clickable: this.btnDisplayFileDialogTarget,
        maxFilesize: 30,
        parallelUploads: 100,
        maxFiles: 100,
        uploadMultiple: true,
        headers: {
          "X-CSRF-TOKEN": document.querySelector("meta[name='csrf-token']").content
        }
      }
    );

    this.dropzone.on("addedfile", this.onFileAdded.bind(this));
    this.dropzone.on("success", this.onFileSuccess.bind(this));
    this.dropzone.on("removedfile", this.onFileRemoved.bind(this));
    this.getFilesFromServer();
  }

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
          this.display(this.subgroupWrapperTarget, true);
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
    this.display(this.subgroupWrapperTarget, false);
  }

  displayVariablesWarning(e) {
    const body = tinymce.activeEditor.getContent();
    this.display(this.variableWarningTarget, body.indexOf("{{caseworker_full_name}}") > -1);
  }

  submit(e) {
    e.preventDefault();
    const dataTransfer = new DataTransfer();
    this.dropzone.getQueuedFiles().forEach(file => dataTransfer.items.add(file));
    this.attachmentsFieldTarget.files = dataTransfer.files;
    this.attachmentsFieldTarget.dispatchEvent(new Event("change"));
    this.element.submit();
  }

  display(element, isVisible) {
    element.classList.remove("govuk-!-display-none");

    if (!isVisible)
      element.classList.add("govuk-!-display-none");
  }

  onFileAdded(file) {
    this.setDownloadLink(file);
    this.display(this.attachmentListTarget, true);
  }

  onFileSuccess(file) {
    this.displayDownloadLink(file);
  }

  onFileRemoved(file) {
    if (this.dropzone.files.length == 0)
      this.display(this.attachmentListTarget, false);
    
    if (file.file_id) {
      const idValues = this.removeAttachmentsFieldTarget.value;
      const idArray = idValues ? JSON.parse(idValues) : [];
      idArray.push(file.file_id);
      this.removeAttachmentsFieldTarget.value = JSON.stringify(idArray);
    }
  }

  getFilesFromServer() {
    if (!this.attachmentListUrlValue)
      return;

    fetch(this.attachmentListUrlValue, { method: "get", headers: { "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').content }})
      .then(res => res.json())
      .then(data => {
        data.forEach(attachment => {
          this.dropzone.emit("addedfile", attachment);
          this.dropzone.emit("success", attachment);
          this.dropzone.emit("complete", attachment);
          this.dropzone.files.push(attachment);
        });
      })
      .catch(err => console.log(err));
  }

  setDownloadLink(file) {
    if (!file.url) {
      return;
    }

    file.previewElement.querySelectorAll("[data-dz-url]").forEach((node) => {
      node.href = file.url;
    });
  }

  displayDownloadLink(file) {
    file.previewElement.querySelectorAll(".template-edit__attachment-download").forEach((node) => {
      this.display(node, file.url);
    });
  }
}
