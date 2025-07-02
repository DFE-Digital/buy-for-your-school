import EmailTemplatesEditController from "./email_templates_edit_controller";

describe("EmailTemplatesEditController", () => {
  let subject;
  const utilities = jest.requireActual("../misc/utilities");

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
    subject.stageSelectTarget = document.createElement("select");
  });

  afterAll(() => {
    jest.restoreAllMocks();
  });

  describe("subgroupSource", () => {
    const groupId = "123";
    const groupText = "Group 1"

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
        event =  {
          target: {
            value: "",
            options: [
              { text: "Group 1" },
              { text: "Group 2" },
            ],
            selectedIndex: 0,
          },
        };
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
        event = {
          target: {
            value: "1",
            options: [
              { text: "Group 1" },
              { text: "Group 2" },
            ],
            selectedIndex: 1,
          },
        };
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
        displaySpy = jest.spyOn(utilities, "display").mockImplementation(() => {});
        
        subject.displayVariablesWarning(null);
      });

      it("calls display with true", () => {
        expect(displaySpy).toHaveBeenCalledWith(subject.variableWarningTarget, true);
      });
    });

    describe("when text content doesn't include {{caseworker_full_name}}", () => {
      beforeEach(() => {
        textContent = "this is test content";
        displaySpy = jest.spyOn(utilities, "display").mockImplementation(() => {});
        
        subject.displayVariablesWarning(null);
      });

      it("calls display with false", () => {
        expect(displaySpy).toHaveBeenCalledWith(subject.variableWarningTarget, false);
      });
    });
  });
});
