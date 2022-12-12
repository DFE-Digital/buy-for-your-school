import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title",
    "lblHint",
    "dropZone",
    "btnContinue",
    "btnAddMoreFiles",
    "btnSubmit"
  ]

  static values = {
    pageOneTitle: String,
    pageOneContinueButton: String,
    pageTwoTitle: String,
    pageTwoContinueButton: String,
    pageThreeTitle: String,
    pageThreeContinueButton: String,
  }

  static outlets = ["dropzone"]

  dropzoneOutletConnected(outlet) {
    outlet.setupOnQueueComplete(this.onDropzoneQueueComplete.bind(this))
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

  continueToPageOne() {
    if (this.currentPage !== 1)
      this.moveFilesFromAddedToAlreadyUploaded()

    this.pageOne()
  }

  continueToPageTwo() {
    if (this.anyFileUploadErrorsOccured()) {
      alert('Please remove any invalid files marked in red')
    } else if (!(this.anyFilesQueuedForUpload() || this.anyFilesUploadedSuccessfully())) {
      alert('Please select a file to upload')
    } else if (!this.anyFilesQueuedForUpload() && this.anyFilesUploadedSuccessfully()) {
      this.continueToPageThree()
    } else {
      this.uploadFiles()
      this.pageTwo()
    }
  }

  continueToPageThree() {
    this.moveFilesFromAlreadyUploadedToAdded()
    this.pageThree()
  }

  // Dropzone event handling

  onDropzoneQueueComplete({ totalEnqueuedFiles, totalUploadedFiles }) {
    // NOTE: the queue can only complete if an upload has been attempted first
    // NOTE: if the queue has completed but there are still enqueued files then an error has occurred with one of the files

    if (totalUploadedFiles === 0 || totalEnqueuedFiles > 0)
      this.continueToPageOne()
    else
      this.continueToPageThree()
  }

  // Presentation

  pageOne() {
    this.currentPage = 1
    this.titleTarget.innerHTML = this.pageOneTitleValue

    this.display(this.lblHintTarget, true)
    this.display(this.dropZoneTarget, true)
    this.display(this.dropzoneOutlet.lblFilesAddedNowTarget, false)
    this.display(this.dropzoneOutlet.filesAddedBeforeTarget, this.anyFilesUploadedSuccessfully())
    this.display(this.btnContinueTarget, true)
    this.display(this.btnSubmitTarget, false)
    this.display(this.btnAddMoreFilesTarget, false)
  }

  pageTwo() {
    this.currentPage = 2
    this.titleTarget.innerHTML = this.pageTwoTitleValue

    this.display(this.lblHintTarget, false)
    this.display(this.dropZoneTarget, false)
    this.display(this.dropzoneOutlet.lblFilesAddedNowTarget, false)
    this.display(this.dropzoneOutlet.filesAddedBeforeTarget, false)
    this.display(this.btnContinueTarget, false)
    this.display(this.btnSubmitTarget, false)
    this.display(this.btnAddMoreFilesTarget, false)
  }

  pageThree() {
    this.currentPage = 3
    this.titleTarget.innerHTML = this.pageThreeTitleValue

    this.display(this.lblHintTarget, false)
    this.display(this.dropZoneTarget, false)
    this.display(this.dropzoneOutlet.lblFilesAddedNowTarget, false)
    this.display(this.dropzoneOutlet.filesAddedBeforeTarget, false)
    this.display(this.btnContinueTarget, false)
    this.display(this.btnSubmitTarget, true)
    this.display(this.btnAddMoreFilesTarget, true)
  }

  display(element, isVisible) {
    element.classList.remove('govuk-!-display-none')

    if (!isVisible)
      element.classList.add('govuk-!-display-none')
  }

  uploadFiles() {
    this.dropzoneOutlet.uploadFiles()
  }

  moveFilesFromAlreadyUploadedToAdded() {
    this.dropzoneOutlet.moveFilesFromAlreadyUploadedToAdded()
  }

  moveFilesFromAddedToAlreadyUploaded() {
    this.dropzoneOutlet.moveFilesFromAddedToAlreadyUploaded()
  }

  // Query methods

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
