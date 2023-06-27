import EmailAttachmentController from "./email_attachment_controller";

describe("EmailAttachmentController", () => {
  let subject;
  let dropzoneFiles = [];
  const utilities = jest.requireActual("../misc/utilities");

  beforeEach(() => {
    subject = new EmailAttachmentController();
    subject.btnUseTemplateTarget = document.createElement("input");
    subject.attachmentListTarget = document.createElement("div");
    subject.fileAttachmentsFieldTarget = document.createElement("input");
    subject.fileAttachmentsFieldTarget.setAttribute("type", "file");
    subject.blobAttachmentsFieldTarget = document.createElement("input");
    subject.dropzone = {
      getQueuedFiles: jest.fn(),
      emit: jest.fn(() => {}),
      files: dropzoneFiles,
    };
  });

  afterAll(() => {
    jest.restoreAllMocks();
  });

  describe("addToBlobAttachments", () => {
    let item;

    beforeEach(() => {
      subject.blobAttachmentsFieldTarget.value = "[\"blob1\"]";
      item = "blob2";

      subject.addToBlobAttachments(item);
    });

    it("adds given item to the blob attachment field", () => {
      expect(subject.blobAttachmentsFieldTarget.value).toEqual("[\"blob1\",\"blob2\"]");
    });
  });

  describe("onFileAdded", () => {
    let file;
    let setDownloadLinkSpy;
    let displaySpy;

    beforeEach(() => {
      file = "file";
      setDownloadLinkSpy = jest.spyOn(subject, "setDownloadLink").mockImplementation(() => {});
      displaySpy = jest.spyOn(utilities, "display").mockImplementation(() => {});
      
      subject.onFileAdded(file);
    });

    it("calls to display attachment list", () => {
      expect(displaySpy).toHaveBeenCalledWith(subject.attachmentListTarget, true);
    });

    it("calls to set the file's download link", () => {
      expect(setDownloadLinkSpy).toHaveBeenCalledWith(file);
    });
  });

  describe("onFileSuccess", () => {
    let file;
    let displayDownloadLinkSpy;

    beforeEach(() => {
      file = "file";
      displayDownloadLinkSpy = jest.spyOn(subject, "displayDownloadLink").mockImplementation(() => {});
      
      subject.onFileSuccess(file);
    });

    it("calls to display a download link", () => {
      expect(displayDownloadLinkSpy).toHaveBeenCalledWith(file);
    });
  });

  describe("onFileRemoved", () => {
    let file;
    let fileId;

    beforeEach(() => {
      file = { file_id: fileId };
    });

    describe("when there are no more files left", () => {
      let displaySpy;

      beforeEach(() => {
        dropzoneFiles = [];
        displaySpy = jest.spyOn(utilities, "display").mockImplementation(() => {});

        subject.onFileRemoved(file);
      });

      it("calls to hide the attachment list", () => {
        expect(displaySpy).toHaveBeenCalledWith(subject.attachmentListTarget, false);
      });
    });
  });

  describe("getFilesFromServer", () => {
    const file = {};
    let files = [];

    beforeEach(() => {
      global.fetch = jest.fn(() =>
        Promise.resolve({
          json: () => Promise.resolve(files)
        })
      );
    });

    beforeAll(() => {
      const meta = document.createElement("meta");
      meta.name = "csrf-token";
      meta.content = "token";
      document.getElementsByTagName('head')[0].appendChild(meta);
    })

    afterEach(() => fetch.mockClear());

    describe("when the attachment list URL is not set", () => {
      beforeEach(() => {
        subject.attachmentListUrlValue = null;

        subject.getFilesFromServer();
      });

      it("returns without fetching", () => {
        expect(fetch).toHaveBeenCalledTimes(0);
      });
    });

    describe("when the attachment list URL is set", () => {
      beforeEach(() => {
        dropzoneFiles = [];
        files = [file];
        subject.attachmentListUrlValue = "/attachment_list";

        subject.getFilesFromServer();
      });

      it("makes a GET request with CSRF header", () => {
        expect(fetch).toHaveBeenCalledWith("/attachment_list", { method: "get", headers: { "X-CSRF-TOKEN": "token" } })
      });

      it("fires 'addedfile' event for each file", () => {
        expect(subject.dropzone.emit).toHaveBeenCalledWith("addedfile", file);
      });

      it("fires 'success' event for each file", () => {
        expect(subject.dropzone.emit).toHaveBeenCalledWith("success", file);
      });

      it("fires 'complete' event for each file", () => {
        expect(subject.dropzone.emit).toHaveBeenCalledWith("complete", file);
      });

      it("pushes each file to the dropzone file list", () => {
        expect(subject.dropzone.files).toEqual([file]);
      });
    });
  });

  describe("displayDownloadLink", () => {
    let file;
    let url;
    let downloadSpan;
    let previewElement;
    let displaySpy;

    beforeEach(() => {
      previewElement = document.createElement("div");
      downloadSpan = document.createElement("span");
      downloadSpan.classList.add("template-edit__attachment-download");
      previewElement.appendChild(downloadSpan);
      displaySpy = jest.spyOn(utilities, "display").mockImplementation(() => {});
  
      file = {
        url: url,
        previewElement: previewElement
      };
    });

    describe("when the file has no URL", () => {
      beforeEach(() => {
        file.url = null;
        subject.displayDownloadLink(file);
      });

      it("calls to hide the link container", () => {
        expect(displaySpy).toHaveBeenCalledWith(downloadSpan, null);
      });
    });

    describe("when the file has a URL", () => {
      beforeEach(() => {
        file.url = "file-url";
        subject.displayDownloadLink(file);
      });

      it("calls to show the link container", () => {
        expect(displaySpy).toHaveBeenCalledWith(downloadSpan, "file-url");
      });
    });
  });

  describe("setDownloadLink", () => {
    let file;
    let url;
    let downloadLink;
    let previewElement;

    beforeEach(() => {
      previewElement = document.createElement("div");
      downloadLink = document.createElement("a");
      downloadLink.setAttribute("data-dz-url", "");
      previewElement.appendChild(downloadLink);
  
      file = {
        url: url,
        previewElement: previewElement
      };
    });

    describe("when the file has no URL", () => {
      beforeEach(() => {
        file.url = null;
        subject.setDownloadLink(file);
      });

      it("does not set the URL", () => {
        expect(downloadLink.href).toEqual("");
      });
    });

    describe("when the file has a URL", () => {
      beforeEach(() => {
        file.url = "file-url";
        subject.setDownloadLink(file);
      });

      it("sets the URL", () => {
        expect(downloadLink.href).toMatch(/^.*\/file-url$/);
      });
    });
  });
});
