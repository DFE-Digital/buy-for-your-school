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
    outlet.setupOnUploadFilesComplete(this.continueToPageThree.bind(this))
  }

  // Actions

  continueToUpload(event) {
    event.preventDefault()
    this.btnContinueTarget.blur()

    if (this.anyFileUploadErrorsOccured()) {
      alert('Please remove any invalid files marked in red')
    } else if (!this.anyFilesQueuedForUpload() && !this.anyFilesUploadedSuccessfully()) {
      alert('Please select a file to upload')
    } else {
      this.pageTwo()
      this.uploadFilesOrContinueToPageThree()
    }
  }

  uploadFilesOrContinueToPageThree() {
    if (this.anyFilesQueuedForUpload())
      this.uploadFiles() // move to page 3 when done
    else
      this.continueToPageThree()
  }

  continueToPageThree() {
    if (this.anyFileUploadErrorsOccured())
      return

    this.moveFilesFromAlreadyUploadedToAdded()
    this.pageThree()
  }

  addMoreFiles(event) {
    event.preventDefault()
    this.btnAddMoreFilesTarget.blur()

    this.pageOne()
    this.display(this.dropzoneOutlet.filesAddedBeforeTarget, true)
    this.moveFilesFromAddedToAlreadyUploaded()
  }

  submit() {
    // noop, allow the form submit event to propogate
  }

  // Presentation

  pageOne() {
    this.titleTarget.innerHTML = this.pageOneTitleValue
    this.btnContinueTarget.innerHTML = this.pageOneContinueButtonValue

    this.display(this.lblHintTarget, true)
    this.display(this.dropZoneTarget, true)
    this.display(this.dropzoneOutlet.lblFilesAddedNowTarget, false)
    this.display(this.dropzoneOutlet.filesAddedBeforeTarget, false)
    this.display(this.btnContinueTarget, true)
    this.display(this.btnSubmitTarget, false)
    this.display(this.btnAddMoreFilesTarget, false)
  }

  pageTwo() {
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
    this.titleTarget.innerHTML = this.pageThreeTitleValue
    this.btnContinueTarget.innerHTML = this.pageThreeContinueButtonValue

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
