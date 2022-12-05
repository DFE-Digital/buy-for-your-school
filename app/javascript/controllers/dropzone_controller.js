import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"

export default class extends Controller {
  static targets = [
    "btnDisplayFileDialog",
    "lblFilesAddedNow",
    "filesAddedBefore"
  ]

  static values = {
    addFileUrl: String,
    removeFileUrl: String
  }

  initialize() {
    this.dropzone = undefined
    this.fileUploadErrors = {}
    this.filesToUpload = []
    this.uploadedFiles = []
    this.onQueueCompleteCallback = () => {}
  }

  connect() {
    const previewsContainer = this.element.querySelector('.file-previews .files-added-now')
    const previewTemplateContainer = this.element.querySelector('.upload-preview-template')
    const previewTemplate = previewTemplateContainer.innerHTML
    previewTemplateContainer.remove()

    this.dropzone = new Dropzone(
      this.element,
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

    this.dropzone.on('removedfile', function(file) {
      controller.onFileRemoved(file)
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

  // Public methods

  setupOnQueueComplete(callback) {
    this.onQueueCompleteCallback = callback
  }

  uploadFiles() {
    this.dropzone.processQueue()
  }

  // File events

  onFileError(file, error) {
    this.display(file.previewElement.querySelector('.progress-status-container'), true)
    this.fileUploadErrors[file] = error
  }

  onFileAdded(file) {
    this.display(this.lblFilesAddedNowTarget, true)
    this.filesToUpload.push(file)
  }

  onFileRemoved(file) {
    if (this.fileHasBeenUploaded(file))
      this.deleteFileFromServer(file)
    else
      this.deleteFileFromUi(file)
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
    if (file.status === "success") {
      this.filesToUpload = this.filesToUpload.filter(f => f != file)

      const { file_id } = JSON.parse(file.xhr.response)
      file.file_id = file_id
      this.uploadedFiles.push(file)
    } else {
      // NOTE: Errors appear automatically on the upload row if the response json has a "error" key
    }
  }

  onQueueComplete() {
    this.onQueueCompleteCallback({
      totalEnqueuedFiles: this.totalEnqueuedFiles(),
      totalUploadedFiles: this.totalUploadedFiles()
    })
  }

  // File actions

  deleteFileFromServer(file) {
    const body = new FormData()
    body.append('file_id', file.file_id)

    fetch(this.removeFileUrlValue, { method: 'DELETE', body })
      .then(() => this.deleteFileFromUi(file))
      .catch((error) => alert(error))
  }

  deleteFileFromUi(file) {
    this.filesToUpload = this.filesToUpload.filter(pendingFile => pendingFile != file)
    delete this.fileUploadErrors[file]

    this.display(this.lblFilesAddedNowTarget, this.anyFilesQueuedForUpload())
  }

  // Presentation

  display(element, isVisible) {
    element.classList.remove('govuk-!-display-none')

    if (!isVisible)
      element.classList.add('govuk-!-display-none')
  }

  moveFilesFromAlreadyUploadedToAdded() {
    const alreadyUploaded = this.element.querySelector('.files-added-before')
    const filesAdded = this.element.querySelector('.files-added-now')

    for (let uploadedFile of alreadyUploaded.querySelectorAll('.upload-item')) {
      filesAdded.appendChild(uploadedFile)
    }
  }

  moveFilesFromAddedToAlreadyUploaded() {
    const alreadyUploaded = this.element.querySelector('.files-added-before')
    const filesAdded = this.element.querySelector('.files-added-now')

    for (let uploadedFile of filesAdded.querySelectorAll('.upload-item')) {
      alreadyUploaded.appendChild(uploadedFile)
    }
  }

  // Query methods

  totalEnqueuedFiles() {
    return this.filesToUpload.length
  }

  totalUploadedFiles() {
    return this.uploadedFiles.length
  }

  anyFilesQueuedForUpload() {
    return this.totalEnqueuedFiles() > 0
  }

  anyFilesUploadedSuccessfully() {
    return this.totalUploadedFiles() > 0
  }

  anyFileUploadErrorsOccured() {
    return Object.keys(this.fileUploadErrors).length > 0
  }

  fileHasBeenUploaded(file) {
    return file.file_id !== undefined
  }
}
