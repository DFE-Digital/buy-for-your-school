import EmailTemplatesEditController from "./email_templates_edit_controller";

describe("EmailTemplatesEditController", () => {
  let subject;
  let dropzoneFiles = [];

  const createOption = (value, text) => {
    const option = document.createElement("option");
    option.setAttribute("value", value);
    option.textContent = text;
    return option;
  };

  beforeEach(() => {
    subject = new EmailTemplatesEditController();
    subject.subgroupUrlValue = "https://test-url.com";
    subject.subgroupSelectTarget = document.createElement("select");
    subject.subgroupWrapperTarget = document.createElement("div");
    subject.variableWarningTarget = document.createElement("div");
    subject.attachmentListTarget = document.createElement("div");
    subject.attachmentsFieldTarget = document.createElement("input");
    subject.attachmentsFieldTarget.setAttribute("type", "file");
    subject.removeAttachmentsFieldTarget = document.createElement("input");
    subject.dropzone = {
      getQueuedFiles: jest.fn(),
      emit: jest.fn(() => {}),
      files: dropzoneFiles,
    };
  });

  afterAll(() => {
    jest.restoreAllMocks();
  });

  describe("subgroupSource", () => {
    const groupId = "123";

    it("concatenates the groupId to the subgroupUrl", () => {
      expect(subject.subgroupSource(groupId)).toEqual("https://test-url.com/123");
    });
  });

  describe("clearSubgroups", () => {
    beforeEach(() => {
      subject.subgroupSelectTarget.replaceChildren(document.createElement("option"));
      subject.clearSubgroups();
    });

    it("removes all the options from the subgroupSelect", () => {
      expect(subject.subgroupSelectTarget.children.length).toEqual(0);
    });

    it("adds hide class to the subgroupWrapper", () => {
      expect(subject.subgroupWrapperTarget).toHaveClass("govuk-!-display-none");
    });
  });

  describe("groupsToOptions", () => {
    let groups;
    let selectText;

    beforeEach(() => {
      groups = [
        { id: 1, title: "Group 1" },
        { id: 2, title: "Group 2" }
      ];
      selectText = "Select group";
    });

    it("transforms a list of groups into options with a blank first option", () => {
      const expected_results = [createOption("", "Select group"), createOption("1", "Group 1"), createOption("2", "Group 2")];
      expect(subject.groupsToOptions(groups, selectText)).toEqual(expected_results);
    });
  });

  describe("populateSubgroups", () => {
    let event;

    describe("when a group with no ID is selected", () => {
      let clearSubgroupsSpy;

      beforeEach(() => {
        event = { target: { value: "" } };
        clearSubgroupsSpy = jest.spyOn(subject, "clearSubgroups").mockImplementation(() => {});
      });

      it("calls clearSubgroups", () => {
        subject.populateSubgroups(event);
        expect(clearSubgroupsSpy).toHaveBeenCalledTimes(1);
      });
    });

    describe("when a group with an ID is selected", () => {
      let data;
      let subgroupSourceSpy;
      let groupsToOptionsSpy;
      const options = [createOption("", "Select group"), createOption("1", "Group 1"), createOption("2", "Group 2")];
      const csrf_token = "token";      

      beforeAll(() => {
        const meta = document.createElement("meta");
        meta.name = "csrf-token";
        meta.content = csrf_token;
        document.getElementsByTagName('head')[0].appendChild(meta);
      })

      beforeEach(() => {
        event = { target: { value: "1" } };
        subgroupSourceSpy = jest.spyOn(subject, "subgroupSource").mockImplementation(() => "https://test-url.com/123");
        groupsToOptionsSpy = jest.spyOn(subject, "groupsToOptions").mockImplementation(() => options);

        global.fetch = jest.fn(() =>
          Promise.resolve({
            json: () => Promise.resolve(data)
          })
        );
      });

      afterEach(() => {
        fetch.mockClear();
      });

      describe("when the group has subgroups", () => {
        beforeEach(() => {
          data = [
            { id: 1, title: "Group 1" },
            { id: 2, title: "Group 2" }
          ];
          subject.subgroupWrapperTarget.classList.add("govuk-!-display-none");

          subject.populateSubgroups(event);
        });

        it("fetches the subgroups and replaces them", () => {
          expect(subgroupSourceSpy).toHaveBeenCalledTimes(1);
          expect(fetch).toHaveBeenCalledWith("https://test-url.com/123", { method: "get", headers: { "X-CSRF-TOKEN": csrf_token }});
          expect(groupsToOptionsSpy).toHaveBeenCalledTimes(1);
          expect(Array.from(subject.subgroupSelectTarget.children)).toEqual(options);
          expect(subject.subgroupWrapperTarget.classList.contains("govuk-!-display-none")).toBe(false);
        });
      });

      describe("when the group has no subgroups", () => {
        let clearSubgroupsSpy;

        beforeEach(() => {
          data = [];
          clearSubgroupsSpy = jest.spyOn(subject, "clearSubgroups").mockImplementation(() => {});

          subject.populateSubgroups(event);
        });

        it("calls clearSubgroups", () => {
          expect(subgroupSourceSpy).toHaveBeenCalledTimes(1);
          expect(fetch).toHaveBeenCalledWith("https://test-url.com/123", { method: "get", headers: { "X-CSRF-TOKEN": csrf_token }});
          expect(clearSubgroupsSpy).toHaveBeenCalledTimes(1);
        });
      });
    });
  });

  describe("displayVariablesWarning", () => {
    let displaySpy;
    let textContent;
    const tinymceMock = { activeEditor: { getContent: jest.fn(() => textContent)} };

    global.tinymce = tinymceMock;

    describe("when text content includes {{caseworker_full_name}}", () => {
      beforeEach(() => {
        textContent = "hi {{caseworker_full_name}}";
        displaySpy = jest.spyOn(subject, "display").mockImplementation(() => {});
        
        subject.displayVariablesWarning(null);
      });

      it("calls display with true", () => {
        expect(displaySpy).toHaveBeenCalledWith(subject.variableWarningTarget, true);
      });
    });

    describe("when text content doesn't include {{caseworker_full_name}}", () => {
      beforeEach(() => {
        textContent = "this is test content";
        displaySpy = jest.spyOn(subject, "display").mockImplementation(() => {});
        
        subject.displayVariablesWarning(null);
      });

      it("calls display with false", () => {
        expect(displaySpy).toHaveBeenCalledWith(subject.variableWarningTarget, false);
      });
    });
  });

  describe("onFileAdded", () => {
    let file;
    let setDownloadLinkSpy;
    let displaySpy;

    beforeEach(() => {
      file = "file";
      setDownloadLinkSpy = jest.spyOn(subject, "setDownloadLink").mockImplementation(() => {});
      displaySpy = jest.spyOn(subject, "display").mockImplementation(() => {});
      
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
        displaySpy = jest.spyOn(subject, "display").mockImplementation(() => {});

        subject.onFileRemoved(file);
      });

      it("calls to hide the attachment list", () => {
        expect(displaySpy).toHaveBeenCalledWith(subject.attachmentListTarget, false);
      });
    });

    describe("when removing an existing file (has file_id)", () => {
      fileId = "testId";

      beforeEach(() => {
        subject.removeAttachmentsFieldTarget.value = "[\"existingId\"]";

        subject.onFileRemoved(file);
      });

      it("updates removed attachment array", () => {
        expect(subject.removeAttachmentsFieldTarget.value).toEqual("[\"existingId\",\"testId\"]");
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
      displaySpy = jest.spyOn(subject, "display").mockImplementation(() => {});
  
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
