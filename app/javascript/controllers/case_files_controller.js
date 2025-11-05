import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"
import { display } from "../misc/utilities"
import ErrorMessage from "../misc/error_message"

// Connects to data-controller="case-files"
export default class extends Controller {
  static targets = [
    "btnDisplayFileDialog",
    "fileList",
    "previewTemplate",
    "filePreview",
    "filesField",
    "title",
    "body"
  ];

  static outlets = [
    "error-summary"
  ]

  initialize() {
    this.fileUploadErrors = {}
    this.onFileErrorCallback = () => {}
    this.onFileRemovedCallback = () => {}
  }

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
    this.dropzone.on('error', this.onFileError.bind(this));
  }

  onFileError(file, error) {
    display(file.previewElement.querySelector('.progress-status-container'), false)
    this.fileUploadErrors[file] = error
    this.onFileErrorCallback(file, error)
    this.errorInvalidFiles.show()
  }

  errorSummaryOutletConnected(outlet) {
    this.errorInvalidFiles = new ErrorMessage(outlet, 'Please remove any invalid files marked in red')
  }

  onFileAdded(file) {
    display(this.fileListTarget, true);
  }

  onFileRemoved(file) {
    delete this.fileUploadErrors[file]
    const hasErrorFiles = this.dropzone.files.some(file => file.status === "error");

    if (!hasErrorFiles)
      this.errorInvalidFiles.hide()
    if (this.dropzone.files.length == 0)
      display(this.fileListTarget, false);
  }

  submit(e) {
    e.preventDefault();
    const hasErrorFiles = this.dropzone.files.some(file => file.status === "error");
    if (hasErrorFiles) {
      return;
    }
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
