import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"

export default class extends Controller {
  static targets = [
    "title",
    "btnContinue",
    "btnDisplayFileDialog",
    "btnAddMoreFiles",
    "btnSubmit",
    "dropZone",
    "lblFilesAddedNow",
    "filesAddedBefore",
    "lblHint"
  ]

  static values = {
    pageOneTitle: String,
    pageOneContinueButton: String,
    pageTwoTitle: String,
    pageTwoContinueButton: String,
    pageThreeTitle: String,
    pageThreeContinueButton: String,
    addFileUrl: String
  }

  connect() {
    this.setupDropZone()
  }

  initialize() {
    this.dropzone = undefined
    this.fileUploadErrors = []
    this.filesToUpload = []
  }

  // Actions

  continueToUpload(event) {
    event.preventDefault()
    this.btnContinueTarget.blur()

    if (this.filesToUpload.length === 0) {
      alert('Please select a file to upload')
    } else if (this.fileUploadErrors.length > 0) {
      alert('Please remove any invalid files marked in red')
    } else {
      this.pageTwo()
      this.uploadFilesOrContinueToPageThree()
    }
  }

  uploadFilesOrContinueToPageThree() {
    if (this.dropzone.getQueuedFiles().length > 0)
      this.dropzone.processQueue() // moves the page 3 when done
    else if (this.fileUploadErrors.length === 0)
      this.continueToPageThree()
  }

  continueToPageThree() {
    this.moveFilesFromAlreadyUploadedToAdded()
    this.pageThree()
  }

  addMoreFiles(event) {
    event.preventDefault()
    this.btnAddMoreFilesTarget.blur()

    this.pageOne()
    this.display(this.filesAddedBeforeTarget, true)
    this.moveFilesFromAddedToAlreadyUploaded()
  }

  submit() {
    // noop, allow the form submit event to propogate
  }

  // Presentation

  pageOne() {
    this.titleTarget.innerHTML = this.pageOneTitleValue
    this.btnContinueTarget.innerHTML = this.pageOneContinueButtonValue

    this.display(this.btnContinueTarget, true)
    this.display(this.btnSubmitTarget, false)
    this.display(this.dropZoneTarget, true)
    this.display(this.lblHintTarget, true)
    this.display(this.lblFilesAddedNowTarget, false)
    this.display(this.filesAddedBeforeTarget, false)
    this.display(this.btnAddMoreFilesTarget, false)
  }

  pageTwo() {
    this.titleTarget.innerHTML = this.pageTwoTitleValue

    this.display(this.btnContinueTarget, false)
    this.display(this.btnSubmitTarget, false)
    this.display(this.dropZoneTarget, false)
    this.display(this.lblHintTarget, false)
    this.display(this.lblFilesAddedNowTarget, false)
    this.display(this.filesAddedBeforeTarget, false)
    this.display(this.btnAddMoreFilesTarget, false)
  }

  pageThree() {
    this.titleTarget.innerHTML = this.pageThreeTitleValue
    this.btnContinueTarget.innerHTML = this.pageThreeContinueButtonValue

    this.display(this.btnContinueTarget, false)
    this.display(this.btnSubmitTarget, true)
    this.display(this.dropZoneTarget, false)
    this.display(this.lblHintTarget, false)
    this.display(this.lblFilesAddedNowTarget, false)
    this.display(this.filesAddedBeforeTarget, false)
    this.display(this.btnAddMoreFilesTarget, true)
  }

  display(element, isVisible) {
    element.classList.remove('govuk-!-display-none')

    if (!isVisible)
      element.classList.add('govuk-!-display-none')
  }

  // Dropzone

  setupDropZone() {
    const container = this.element.querySelector('.drop-zone-container')
    const previewsContainer = container.querySelector('.file-previews .files-added-now')

    const previewTemplateContainer = container.querySelector('.upload-preview-template')
    const previewTemplate = previewTemplateContainer.innerHTML
    previewTemplateContainer.remove()

    this.dropzone = new Dropzone(
      container,
      {
        url: this.addFileUrlValue,
        parallelUploads: 3,
        previewTemplate,
        previewsContainer,
        autoProcessQueue: false,
        clickable: this.btnDisplayFileDialogTarget,
        maxFilesize: 200
      }
    )

    const controller = this

    this.dropzone.on('addedfile', function(file) {
      controller.onFileAdded(file)
    })

    this.dropzone.on('error', function(file, error) {
      controller.onFileError(file, error)
    })

    this.dropzone.on('uploadprogress', function(file, progress) {
      controller.onUploadProgress(file, progress)
    })

    this.dropzone.on('complete', function(file) {
      controller.onFileUploadComplete(file)
    })

    this.dropzone.on('queuecomplete', function() {
      controller.onQueueComplete()
    })
  }

  // Dropzone events

  onFileError(file, error) {
    this.display(file.previewElement.querySelector('.progress-status-container'), true)
    this.fileUploadErrors.push(error)
  }

  onFileAdded(file) {
    this.display(this.lblFilesAddedNowTarget, true)
    this.filesToUpload.push(file)
  }

  onUploadProgress(file, progress) {
    const status = progress === 100 ? 'Complete' : 'Uploading'

    const statusContainer = file.previewElement.querySelector('.progress-status')
    statusContainer.classList.remove("uploading", "complete")
    statusContainer.classList.add(status.toLowerCase())
    statusContainer.innerHTML = status

    file.previewElement.querySelector('[data-dz-uploadprogress]').style.width = progress

    for (let hiddenElement of file.previewElement.querySelectorAll(".govuk-\\!-display-none")) {
      this.display(hiddenElement, true)
    }
  }

  onFileUploadComplete(file) {
    console.log(file)
  }

  onQueueComplete() {
    this.continueToPageThree()
  }

  // Dropzone presentational

  moveFilesFromAlreadyUploadedToAdded() {
    const container = this.element.querySelector('.drop-zone-container')
    const alreadyUploaded = container.querySelector('.files-added-before')
    const filesAdded = container.querySelector('.files-added-now')

    for (let uploadedFile of alreadyUploaded.querySelectorAll('.upload-item')) {
      filesAdded.appendChild(uploadedFile)
    }
  }

  moveFilesFromAddedToAlreadyUploaded() {
    const container = this.element.querySelector('.drop-zone-container')
    const alreadyUploaded = container.querySelector('.files-added-before')
    const filesAdded = container.querySelector('.files-added-now')

    for (let uploadedFile of filesAdded.querySelectorAll('.upload-item')) {
      alreadyUploaded.appendChild(uploadedFile)
    }
  }
}
