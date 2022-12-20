import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"

export default class extends Controller {
  static targets = [
    "btnDisplayFileDialog",
    "filePreview",
    "previewTemplate"
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
    this.onFileErrorCallback = () => {}
    this.onFileRemovedCallback = () => {}
    this.onFileAddedCallback = () => {}
  }

  connect() {
    const previewTemplateContainer = this.element.querySelector('.upload-preview-template')
    const previewTemplate = previewTemplateContainer.innerHTML
    previewTemplateContainer.remove()

    this.dropzone = new Dropzone(
      this.element,
      {
        url: this.addFileUrlValue,
        parallelUploads: 3,
        previewTemplate,
        previewsContainer: this.filePreviewTarget,
        autoProcessQueue: false,
        clickable: this.btnDisplayFileDialogTarget,
        maxFilesize: 200
      }
    )

    this.dropzone.on('addedfile', (file) => {
      this.onFileAdded(file)
    })

    this.dropzone.on('error', (file, error) => {
      this.onFileError(file, error)
    })

    this.dropzone.on('removedfile', (file) => {
      this.onFileRemoved(file)
    })

    this.dropzone.on('uploadprogress', (file, progress) => {
      this.onUploadProgress(file, progress)
    })

    this.dropzone.on('complete', (file) => {
      this.onFileUploadComplete(file)
    })

    this.dropzone.on('queuecomplete', () => {
      this.onQueueComplete()
    })
  }

  // Public methods

  setupOnQueueComplete(callback) {
    this.onQueueCompleteCallback = callback
  }

  setupOnFileError(callback) {
    this.onFileErrorCallback = callback
  }

  setupOnFileRemoved(callback) {
    this.onFileRemovedCallback = callback
  }

  setupOnFileAdded(callback) {
    this.onFileAddedCallback = callback
  }

  uploadFiles() {
    this.dropzone.processQueue()
  }

  // File events

  onFileError(file, error) {
    this.display(file.previewElement.querySelector('.progress-status-container'), true)
    this.fileUploadErrors[file] = error
    this.onFileErrorCallback(file, error)
  }

  onFileAdded(file) {
    this.filesToUpload.push(file)
    this.onFileAddedCallback(file)
  }

  onFileRemoved(file) {
    const potentiallyDeleteFileFromServer = new Promise((resolve, reject) => {
      if (this.fileHasBeenUploaded(file))
        this.deleteFileFromServer(file).then(resolve)
      else
        resolve()
    })

    potentiallyDeleteFileFromServer.then(() => {
      this.filesToUpload = this.filesToUpload.filter(pendingFile => pendingFile != file)
      this.uploadedFiles = this.uploadedFiles.filter(uploadedFile => uploadedFile != file)

      const existingErrorForFile = this.fileUploadErrors[file]
      delete this.fileUploadErrors[file]

      this.onFileRemovedCallback(file, existingErrorForFile)
    })
  }

  onUploadProgress(file, progress) {
    const status = progress === 100 ? 'Complete' : 'Uploading'

    const statusContainer = file.previewElement.querySelector('.progress-status')
    statusContainer.classList.remove("uploading", "complete")
    statusContainer.classList.add(status.toLowerCase())
    statusContainer.innerHTML = status

    const uploadProgressContainer = file.previewElement.querySelector('.upload-progress-container')
    uploadProgressContainer.querySelector('[data-dz-uploadprogress]').style.width = progress

    this.display(statusContainer, true)
    this.display(uploadProgressContainer, true)
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

    return fetch(this.removeFileUrlValue, { method: 'DELETE', body })
  }

  // Presentation

  display(element, isVisible) {
    element.classList.remove('govuk-!-display-none')

    if (!isVisible)
      element.classList.add('govuk-!-display-none')
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
