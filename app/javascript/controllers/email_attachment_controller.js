import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"
import { display } from "../misc/utilities"

// Connects to data-controller="email-attachment"
export default class extends Controller {
  static targets = [
    "btnDisplayFileDialog",
    "attachmentList",
    "previewTemplate",
    "attachmentPreview",
    "fileAttachmentsField",
    "blobAttachmentsField"
  ];
  static values = { attachmentListUrl: String };

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
        maxFilesize: 80,
        parallelUploads: 100,
        maxFiles: 100,
        uploadMultiple: true,
        headers: {
          "X-CSRF-TOKEN": document.querySelector("meta[name='csrf-token']")?.content
        }
      }
    );

    this.dropzone.on("addedfile", this.onFileAdded.bind(this));
    this.dropzone.on("success", this.onFileSuccess.bind(this));
    this.dropzone.on("removedfile", this.onFileRemoved.bind(this));
    this.getFilesFromServer();
  }

  submit(e) {
    e.preventDefault();
    this.prepareAttachmentsForSubmission();
    this.element.requestSubmit();
  }

  prepareAttachmentsForSubmission() {
    const dataTransfer = new DataTransfer();
    this.dropzone.files.forEach(item => {
      if (item instanceof File) {
        dataTransfer.items.add(item);
      } else {
        this.addToBlobAttachments(item);
      }
    });
    this.fileAttachmentsFieldTarget.files = dataTransfer.files;
    this.fileAttachmentsFieldTarget.dispatchEvent(new Event("change"));
  }

  addToBlobAttachments(item) {
    const blobValues = this.blobAttachmentsFieldTarget.value;
    const blobArray = blobValues ? JSON.parse(blobValues) : [];
    blobArray.push(item);
    this.blobAttachmentsFieldTarget.value = JSON.stringify(blobArray);
  }

  onFileAdded(file) {
    this.setDownloadLink(file);
    display(this.attachmentListTarget, true);
  }

  onFileSuccess(file) {
    this.displayDownloadLink(file);
  }

  onFileRemoved(file) {
    if (this.dropzone.files.length == 0)
      display(this.attachmentListTarget, false);
  }

  getFilesFromServer() {
    if (!this.attachmentListUrlValue)
      return;

    fetch(this.attachmentListUrlValue, { method: "get", headers: { "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]')?.content }})
      .then(res => res.json())
      .then(data => {
        data.forEach(attachment => {
          this.dropzone.emit("addedfile", attachment);
          this.dropzone.emit("success", attachment);
          this.dropzone.emit("complete", attachment);
          this.dropzone.files.push(attachment);
        })
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
      display(node, file.url);
    });
  }
}
