import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"
import { display } from "../misc/utilities"

// Connects to data-controller="case-files"
export default class extends Controller {
  static targets = [
    "btnDisplayFileDialog",
    "fileList",
    "previewTemplate",
    "filePreview",
    "filesField"
  ];

  connect() {
    const previewTemplate = this.previewTemplateTarget.innerHTML;
    this.previewTemplateTarget.parentNode.removeChild(this.previewTemplateTarget);

    this.dropzone = new Dropzone(
      this.element,
      {
        previewTemplate: previewTemplate,
        previewsContainer: this.filePreviewTarget,
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
    this.dropzone.on("removedfile", this.onFileRemoved.bind(this));
  }


  onFileAdded(file) {
    display(this.fileListTarget, true);
  }

  onFileRemoved(file) {
    if (this.dropzone.files.length == 0)
      display(this.fileListTarget, false);
  }

  submit(e) {
    e.preventDefault();
    this.prepareAttachmentsForSubmission();
    this.element.requestSubmit();
  }

  prepareAttachmentsForSubmission() {
    const dataTransfer = new DataTransfer();
    this.dropzone.files.forEach(item => dataTransfer.items.add(item));
    this.filesFieldTarget.files = dataTransfer.files;
    this.filesFieldTarget.dispatchEvent(new Event("change"));
  }
}
