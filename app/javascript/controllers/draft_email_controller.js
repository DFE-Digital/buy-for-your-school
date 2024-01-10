import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"
import { display, enable } from "../misc/utilities"

// Connects to data-controller="draft-email"
export default class extends Controller {
  static targets = [
    "emailAttachmentsLink",
    "caseFilesLink",
    "form",
    "btnDisplayFileDialog",
    "attachmentList",
    "previewTemplate",
    "attachmentPreview",
    "btnSubmit"
  ];
  static values = {
    formScope: String,
    updateEndpoint: String,
    listAttachmentsEndpoint: String,
    uploadAttachmentsEndpoint: String,
    removeAttachmentsEndpoint: String
  };

  connect() {
    this.assignLinkHandlers();

    const previewTemplate = this.previewTemplateTarget.innerHTML;
    this.previewTemplateTarget.parentNode.removeChild(this.previewTemplateTarget);

    this.dropzone = new Dropzone(
      this.element,
      {
        url: this.uploadAttachmentsEndpointValue,
        previewTemplate: previewTemplate,
        previewsContainer: this.attachmentPreviewTarget,
        autoProcessQueue: true,
        clickable: this.btnDisplayFileDialogTarget,
        maxFilesize: 30,
        parallelUploads: 4,
        maxFiles: 100,
        uploadMultiple: false,
        headers: {
          "X-CSRF-TOKEN": document.querySelector("meta[name='csrf-token']")?.content
        }
      }
    );
    this.dropzone.on("addedfile", this.onFileAdded.bind(this));
    this.dropzone.on("success", this.onFileSuccess.bind(this));
    this.dropzone.on("removedfile", this.onFileRemoved.bind(this));
    this.dropzone.on("error", this.onFileError.bind(this));
    this.dropzone.on("queuecomplete", this.onQueueComplete.bind(this));
    this.dropzone.on("uploadprogress", this.onFileUploading.bind(this));
    this.getAttachmentsFromServer();
  }

  assignLinkHandlers() {
    this.emailAttachmentsLinkTarget.addEventListener("click", this.onLinkClick.bind(this));
    if (this.hasCaseFilesLinkTarget)
      this.caseFilesLinkTarget.addEventListener("click", this.onLinkClick.bind(this));
  }

  onLinkClick(e) {
    e.preventDefault();
    this.updateEmail();
    this.formTarget.closest("turbo-frame").src = e.target.href;
  }

  updateEmail() {
    tinymce.activeEditor.save();
    fetch(this.updateEndpointValue, {
      method: "PATCH",
      headers: { "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]')?.content },
      body: new FormData(this.formTarget)
    })
      .catch(err => console.log(err));
  }

  getAttachmentsFromServer() {
    fetch(this.listAttachmentsEndpointValue, { method: "get", headers: { "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]')?.content }})
      .then(res => res.json())
      .then(data => {
        data.forEach(file => {
          this.dropzone.emit("addedfile", file);
          file.status = "success";
          this.dropzone.emit("complete", file);
          this.dropzone.files.push(file);
        });
        if (data.length > 0) this.dropzone.emit("queuecomplete");
      });
  }

  onFileAdded(file) {
    display(this.attachmentListTarget, true);
    enable(this.btnSubmitTarget, false);
  }

  onFileSuccess(file, response) {
    file.file_id = response.file_id;
  }

  onFileRemoved(file) {
    const body = new FormData();
    body.append("file_id", file.file_id);

    fetch(this.removeAttachmentsEndpointValue, { method: "DELETE", headers: { "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]')?.content }, body });

    if (this.dropzone.files.length == 0)
      display(this.attachmentListTarget, false);
  }

  onFileError(file, response) {
    const errorContainer = file.previewTemplate.querySelector("[data-dz-error]");
    const progressContainer = this.progressContainer(file);
    errorContainer.innerHTML = response.file[0];
    display(errorContainer, true);
    display(progressContainer, false);
  }

  onQueueComplete() {
    enable(this.btnSubmitTarget, true);
  }

  onFileUploading(file, progress, bytesSent) {
    const progressContainer = this.progressContainer(file);
    progressContainer.innerHTML = progress === 100 ? "Complete" : `${progress.toFixed(0)}% uploaded`;
    progressContainer.value = progress;
    progressContainer.setAttribute("aria-valuenow", progress);

    display(progressContainer, true);
  }

  progressContainer(file) {
    return file.previewElement.querySelector("[data-dz-uploadprogress]");
  }
}
