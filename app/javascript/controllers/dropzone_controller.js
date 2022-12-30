import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"

export default class extends Controller {
  static targets = [
    "btnDisplayFileDialog",
    "filePreview",
    "previewTemplate"
  ]

  static values = {
    listFilesUrl: String,
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
    this.listFilesUrlValue = this.currentPath() + this.listFilesUrlValue
    this.addFileUrlValue = this.currentPath() + this.addFileUrlValue
    this.removeFileUrlValue = this.currentPath() + this.removeFileUrlValue
  }

  connect() {
    const previewTemplateContainer = this.element.querySelector('.upload-preview-template')
    const previewTemplate = previewTemplateContainer.innerHTML
    previewTemplateContainer.remove()

    this.dropzone = new Dropzone(
      this.element,
      {
        url: this.addFileUrlValue,
        parallelUploads: 4,
        previewTemplate,
        previewsContainer: this.filePreviewTarget,
        autoProcessQueue: false,
        clickable: this.btnDisplayFileDialogTarget,
        maxFilesize: 200,
        headers: {
          'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
        }
      }
    )

    this.dropzone.on('addedfile', this.onFileAdded.bind(this))
    this.dropzone.on('error', this.onFileError.bind(this))
    this.dropzone.on('removedfile', this.onFileRemoved.bind(this))
    this.dropzone.on('uploadprogress', this.onUploadProgress.bind(this))
    this.dropzone.on('complete', this.onFileUploadComplete.bind(this))
    this.dropzone.on('queuecomplete', this.onQueueComplete.bind(this))
  }

  currentPath() {
    return window.location.pathname.replace("/edit", "")
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

  getFilesFromServer() {
    fetch(this.listFilesUrlValue, { method: "get", headers: { "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').content }})
      .then(res => res.json())
      .then(data => {
        data.forEach(file => {
          this.dropzone.emit("addedfile", file)
          file.status = "success"
          this.dropzone.emit("complete", file)
        })
        if (data.length > 0) this.dropzone.emit("queuecomplete")
      })
  }

  uploadFiles() {
    const uploadFilesInterval = setInterval(() => {
      if (this.anyFilesQueuedForUpload())
        this.dropzone.processQueue()
      else
        clearInterval(uploadFilesInterval)
    }, 150)
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
    const statusContainer = file.previewElement.querySelector('.progress-status')
    statusContainer.classList.remove("uploading", "complete")
    statusContainer.classList.add(progress === 100 ? 'complete' : 'uploading')
    statusContainer.innerHTML = progress === 100 ? 'Complete' : `${progress.toFixed(0)}% uploaded`

    const uploadProgressContainer = file.previewElement.querySelector('.upload-progress-container')
    const progressElement = uploadProgressContainer.querySelector('.upload-progress')
    progressElement.value = progress
    progressElement.setAttribute('aria-valuenow', progress)

    this.display(statusContainer, true)
    this.display(uploadProgressContainer, true)
  }

  onFileUploadComplete(file) {
    if (file.status === "success") {
      this.filesToUpload = this.filesToUpload.filter(f => f != file)

      if (!file.file_id) {
        const { file_id } = JSON.parse(file.xhr.response)
        file.file_id = file_id
      }
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
