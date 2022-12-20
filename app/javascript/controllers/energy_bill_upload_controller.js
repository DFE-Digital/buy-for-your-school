import { Controller } from "@hotwired/stimulus"
import ErrorMessage from "../misc/error_message"

export default class extends Controller {
  static targets = [
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
    pageOneTitle: String,
    pageTwoTitle: String,
    pageThreeTitle: String
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
  }

  errorSummaryOutletConnected(outlet) {
    this.errorInvalidFiles = new ErrorMessage(outlet, 'Please remove any invalid files marked in red')
    this.errorSelectFiles = new ErrorMessage(outlet, 'Please select one or more files to upload')
  }

  initialize() {
    this.currentPage = 1
  }

  // Button handlers

  onContinueToUploadClicked(event) {
    event.preventDefault()
    this.btnContinueTarget.blur()
    this.continueToPageTwo()
  }

  onAddMoreFilesClicked(event) {
    event.preventDefault()
    this.btnAddMoreFilesTarget.blur()
    this.continueToPageOne()
  }

  onSubmitClicked() {
    // noop, allow the form submit event to propogate
  }

  // Routing
  // standard path: 1 -> 2 -> 3
  // add more files: 3 -> 1 -> 2 -> 3
  // add more files (not adding any more): 3 -> 1 -> 3

  continueToPageOne() {
    if (this.currentPage !== 1)
      this.moveFilesFromAddedToAlreadyUploaded()

    this.pageOne()
  }

  continueToPageTwo() {
    if (this.anyFileUploadErrorsOccured()) {
      this.errorInvalidFiles.show()
      return
    }

    if (this.anyFilesQueuedForUpload()) {
      this.uploadFiles()
      this.pageTwo()
    } else if (this.anyFilesUploadedSuccessfully()) {
      this.continueToPageThree()
    } else {
      this.errorSelectFiles.show()
    }
  }

  continueToPageThree() {
    this.moveFilesFromAlreadyUploadedToAdded()
    this.pageThree()
  }

  // Dropzone event handling

  onDropzoneQueueComplete({ totalEnqueuedFiles, totalUploadedFiles }) {
    // NOTE: this event fires when all uploads have occurred AND if not yet uploaded files have errors
    // NOTE: if the queue has completed but there are still enqueued files then an error has occurred with one of the files

    if (totalUploadedFiles === 0 || totalEnqueuedFiles > 0)
      this.continueToPageOne()
    else
      this.continueToPageThree()
  }

  onDropzoneFileError() {
    this.errorInvalidFiles.show()
  }

  onDropzoneFileRemoved() {
    if (!this.anyFileUploadErrorsOccured())
      this.errorInvalidFiles.hide()

    if (this.currentPage === 3 && !this.anyFilesUploadedSuccessfully())
      this.continueToPageOne()
    else if (this.currentPage === 1)
      this.pageOne()
  }

  onDropzoneFileAdded() {
    this.errorSelectFiles.hide()

    if (this.currentPage === 1)
      this.showFilePreviews(this.filesAddedNowTarget, true)
  }

  // Presentation

  pageOne() {
    this.currentPage = 1
    this.titleTarget.innerHTML = this.pageOneTitleValue

    this.display(this.lblHintTarget, true)
    this.display(this.dropZoneTarget, true)
    this.showFilePreviews(this.filesAddedNowTarget, this.anyFilesQueuedForUpload())
    this.showFilePreviews(this.filesAddedBeforeTarget, this.anyFilesUploadedSuccessfully())
    this.display(this.btnContinueTarget, true)
    this.display(this.btnSubmitTarget, false)
    this.display(this.btnAddMoreFilesTarget, false)
  }

  pageTwo() {
    this.currentPage = 2
    this.titleTarget.innerHTML = this.pageTwoTitleValue

    this.display(this.lblHintTarget, false)
    this.display(this.dropZoneTarget, false)
    this.showFilePreviews(this.filesAddedNowTarget, true, false)
    this.showFilePreviews(this.filesAddedBeforeTarget, false)
    this.display(this.btnContinueTarget, false)
    this.display(this.btnSubmitTarget, false)
    this.display(this.btnAddMoreFilesTarget, false)
  }

  pageThree() {
    this.currentPage = 3
    this.titleTarget.innerHTML = this.pageThreeTitleValue

    this.display(this.lblHintTarget, false)
    this.display(this.dropZoneTarget, false)
    this.showFilePreviews(this.filesAddedNowTarget, true, false)
    this.showFilePreviews(this.filesAddedBeforeTarget, false)
    this.display(this.btnContinueTarget, false)
    this.display(this.btnSubmitTarget, true)
    this.display(this.btnAddMoreFilesTarget, true)
  }

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

  uploadFiles() {
    this.dropzoneOutlet.uploadFiles()
  }

  moveFilesFromAlreadyUploadedToAdded() {
    for (let uploadedFile of this.filesAddedBeforeTarget.querySelectorAll('.upload-item')) {
      this.filesAddedNowTarget.appendChild(uploadedFile)
    }
  }

  moveFilesFromAddedToAlreadyUploaded() {
    for (let uploadedFile of this.filesAddedNowTarget.querySelectorAll('.upload-item:not(.dz-error)')) {
      this.filesAddedBeforeTarget.appendChild(uploadedFile)
    }
  }

  // Queries

  anyFilesQueuedForUpload() {
    return this.dropzoneOutlet.anyFilesQueuedForUpload()
  }

  anyFilesUploadedSuccessfully() {
    return this.dropzoneOutlet.anyFilesUploadedSuccessfully()
  }

  anyFileUploadErrorsOccured() {
    return this.dropzoneOutlet.anyFileUploadErrorsOccured()
  }
}
