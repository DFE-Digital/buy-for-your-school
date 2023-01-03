import { before } from 'lodash';
import DropzoneController from './dropzone_controller';

describe('DropzoneController', () => {
  let subject

  beforeEach(() => {
    subject = new DropzoneController()
    subject.listFilesUrlValue = "/list"
    subject.addFileUrlValue = "/upload"
    subject.removeFileUrlValue = "/delete"
  })

  describe("getFilesFromServer", () => {
    const file = {}
    let files = []

    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve(files)
      })
    )

    beforeAll(() => {
      const meta = document.createElement("meta")
      meta.name = "csrf-token"
      meta.content = "token"
      document.getElementsByTagName('head')[0].appendChild(meta)
    })

    beforeEach(() => {
      subject.dropzone = { emit: jest.fn(() => {}) }
    })

    it("makes a GET request with CSRF header", () => {
      subject.getFilesFromServer()
      expect(fetch).toHaveBeenCalledWith("/list", { method: "get", headers: { "X-CSRF-TOKEN": "token" } })
    })

    describe("when there are files", () => {
      beforeEach(() => {
        files = [file]
        subject.getFilesFromServer()
      })

      it("fires 'addedfile' event for each file", () => {
        expect(subject.dropzone.emit).toHaveBeenCalledWith("addedfile", file)
      })
  
      it("sets the status to 'success' for each file", () => {
        expect(file.status).toEqual("success")
      })
  
      it("fires 'complete' event for each file", () => {
        expect(subject.dropzone.emit).toHaveBeenCalledWith("complete", file)
      })
  
      it("fires 'queuecomplete' event", () => {
        expect(subject.dropzone.emit).toHaveBeenCalledWith("queuecomplete")
      })
    })

    describe("when there are no files", () => {
      beforeEach(() => {
        files = []
        subject.getFilesFromServer()
      })

      it("does not fire 'queuecomplete' event", () => {
        expect(subject.dropzone.emit).not.toHaveBeenCalledWith("queuecomplete")
      })
    })
  })

  describe("onFileUploadComplete", () => {
    const file = { status: "success", xhr: { response: "{ \"file_id\": \"id\" }"} }

    beforeEach(() => {
      subject.filesToUpload = [file]
      subject.uploadedFiles = []

      subject.onFileUploadComplete(file)
    })

    it("removes the file from filesToUpload", () => {
      expect(subject.filesToUpload.length).toEqual(0)
    })

    it("adds the file to uploadedFiles", () => {
      expect(subject.uploadedFiles.length).toEqual(1)
      expect(subject.uploadedFiles).toContain(file)
    })

    it("sets the file_id", () => {
      expect(file.file_id).toEqual("id")
    })
  })
});
