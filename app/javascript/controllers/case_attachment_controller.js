import {Controller} from "@hotwired/stimulus"
import ErrorMessage from "../misc/error_message"

export default class extends Controller {
    static targets = [
        "form",
        "title",
        "lblHint",
        "dropZone",
        "filesAddedNow",
        "filesAddedBefore",
        "btnContinue",
        "btnAddMoreFiles",
        "btnSubmit"
    ]

    static values = {
        reference: String
    }

    static outlets = [
        "dropzone",
        "error-summary"
    ]

    dropzoneOutletConnected(outlet) {
        outlet.setupOnQueueComplete(this.onDropzoneQueueComplete.bind(this))
        outlet.setupOnFileError(this.onDropzoneFileError.bind(this))
        outlet.setupOnFileRemoved(this.onDropzoneFileRemoved.bind(this))
        outlet.setupOnFileAdded(this.onDropzoneFileAdded.bind(this))
        this.getFilesFromServer()
    }

    errorSummaryOutletConnected(outlet) {
        this.errorInvalidFiles = new ErrorMessage(outlet, 'Please remove any invalid files marked in red')
        this.errorSelectFiles = new ErrorMessage(outlet, 'Please select one or more files to upload')
    }

    initialize() {
        // No-op.
    }

    onFormSubmitted(event) {
        if (this.anyFilesQueuedForUpload()) {
            event.preventDefault();
            this.uploading = true;
            this.uploadFiles();
        }
    }

    // Dropzone event handling

    onDropzoneQueueComplete({totalEnqueuedFiles, totalUploadedFiles}) {
        if (this.uploading && totalEnqueuedFiles === 0 && totalUploadedFiles > 0)
            setTimeout(() => this.formTarget.submit(), 250);
    }

    onDropzoneFileError() {
        this.errorInvalidFiles.show()
    }

    onDropzoneFileRemoved() {
    }

    onDropzoneFileAdded() {
        this.showFilePreviews(this.filesAddedNowTarget, true)
    }

    // Presentation

    display(element, isVisible) {
        element.classList.remove('govuk-!-display-none')

        if (!isVisible)
            element.classList.add('govuk-!-display-none')
    }

    showFilePreviews(element, elementIsVisible, titleIsVisible = undefined) {
        this.display(element, elementIsVisible)
        this.display(element.querySelector('h2'), titleIsVisible === undefined ? elementIsVisible : titleIsVisible)
    }

    // Commands

    getFilesFromServer() {
        this.dropzoneOutlet.getFilesFromServer()
    }

    uploadFiles() {
        this.dropzoneOutlet.uploadFiles()
    }

    // Queries

    anyFilesQueuedForUpload() {
        return this.dropzoneOutlet.anyFilesQueuedForUpload()
    }

    anyFilesUploadedSuccessfully() {
        return this.dropzoneOutlet.anyFilesUploadedSuccessfully()
    }

    anyFileUploadErrorsOccurred() {
        return this.dropzoneOutlet.anyFileUploadErrorsOccurred()
    }
}
