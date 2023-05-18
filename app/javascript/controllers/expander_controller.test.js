import ExpanderController from "./expander_controller";

describe("ExpanderController", () => {
  let subject;

  beforeEach(() => {
    subject = new ExpanderController();
    subject.expandedValue = false;
    subject.expanderTarget = document.createElement("div");
    subject.chevronTarget = document.createElement("span");
    subject.contentTarget = document.createElement("div");
  });

  describe("connect", () => {
    let setExpandedSpy;
    let setDisabledSpy;
    let isDisabledSpy;

    beforeEach(() => {
      setExpandedSpy = jest.spyOn(subject, "setExpanded").mockImplementation(() => {});
      setDisabledSpy = jest.spyOn(subject, "setDisabled").mockImplementation(() => {});
      isDisabledSpy = jest.spyOn(subject, "isDisabled").mockImplementation(() => true);

      subject.connect();
    });

    it("sets expanded and disabled", () => {
      expect(setExpandedSpy).toHaveBeenCalledWith(false);
      expect(isDisabledSpy).toHaveBeenCalledTimes(1);
      expect(setDisabledSpy).toHaveBeenCalledWith(true);
    });
  });

  describe("isDisabled", () => {
    describe("when the expander has the disabled attribute", () => {
      beforeEach(() => {
        subject.expanderTarget.setAttribute("disabled", true);
      });

      it("returns true", () => {
        expect(subject.isDisabled()).toBe(true);
      });
    });

    describe("when the expander does not have the disabled attribute", () => {
      beforeEach(() => {
        subject.expanderTarget.removeAttribute("disabled");
      });

      it("returns false", () => {
        expect(subject.isDisabled()).toBe(false);
      });
    });
  });

  describe("isExpanded", () => {
    describe("when the expander has the expanded class", () => {
      beforeEach(() => {
        subject.expanderTarget.classList.add("expander__expanded");
      });

      it("returns true", () => {
        expect(subject.isExpanded()).toBe(true);
      });
    });

    describe("when the expander does not have the expanded", () => {
      beforeEach(() => {
        subject.expanderTarget.classList.remove("expander__expanded");
      });

      it("returns false", () => {
        expect(subject.isExpanded()).toBe(false);
      });
    });
  });

  describe("setExpanded", () => {
    describe("when true", () => {
      beforeEach(() => {
        subject.expanderTarget.classList.remove("expander__expanded");
        subject.chevronTarget.classList.remove("expander__chevron--down");
        subject.contentTarget.classList.add("govuk-!-display-none");
        subject.contentTarget.setAttribute("aria-expanded", false);

        subject.setExpanded(true);
      });

      it("sets the expanded class", () => {
        expect(subject.expanderTarget.classList.contains("expander__expanded")).toBe(true);
      });

      it("sets the chevron--down class", () => {
        expect(subject.chevronTarget.classList.contains("expander__chevron--down")).toBe(true);
      });

      it("removes the content hide class", () => {
        expect(subject.contentTarget.classList.contains("govuk-!-display-none")).toBe(false);
      });

      it("sets aria-expanded to true", () => {
        expect(subject.contentTarget.getAttribute("aria-expanded")).toEqual("true");
      });
    });

    describe("when false", () => {
      beforeEach(() => {
        subject.expanderTarget.classList.add("expander__expanded");
        subject.chevronTarget.classList.add("expander__chevron--down");
        subject.contentTarget.classList.remove("govuk-!-display-none");
        subject.contentTarget.setAttribute("aria-expanded", true);

        subject.setExpanded(false);
      });

      it("removes the expanded class", () => {
        expect(subject.expanderTarget.classList.contains("expander__expanded")).toBe(false);
      });

      it("removes the chevron--down class", () => {
        expect(subject.chevronTarget.classList.contains("expander__chevron--down")).toBe(false);
      });

      it("sets the content hide class", () => {
        expect(subject.contentTarget.classList.contains("govuk-!-display-none")).toBe(true);
      });

      it("sets aria-expanded to false", () => {
        expect(subject.contentTarget.getAttribute("aria-expanded")).toEqual("false");
      });
    });
  });

  describe("toggleContent", () => {
    let isDisabledSpy;
    let setExpandedSpy;

    beforeEach(() => {
      setExpandedSpy = jest.spyOn(subject, "setExpanded").mockImplementation(() => {});
    });

    describe("when disabled", () => {
      beforeEach(() => {
        isDisabledSpy = jest.spyOn(subject, "isDisabled").mockImplementation(() => true);

        subject.toggleContent();
      });

      it("does not toggle", () => {
        expect(isDisabledSpy).toHaveBeenCalledTimes(1);
        expect(setExpandedSpy).toHaveBeenCalledTimes(0);
      });
    });

    describe("when enabled", () => {
      beforeEach(() => {
        isDisabledSpy = jest.spyOn(subject, "isDisabled").mockImplementation(() => false);
      });

      describe("when expanded", () => {
        beforeEach(() => {
          jest.spyOn(subject, "isExpanded").mockImplementation(() => true);

          subject.toggleContent();
        });

        it("toggles collapse", () => {
          expect(isDisabledSpy).toHaveBeenCalledTimes(1);
          expect(setExpandedSpy).toHaveBeenCalledWith(false);
        });
      });

      describe("when collapsed", () => {
        beforeEach(() => {
          jest.spyOn(subject, "isExpanded").mockImplementation(() => false);

          subject.toggleContent();
        });

        it("toggles expansion", () => {
          expect(isDisabledSpy).toHaveBeenCalledTimes(1);
          expect(setExpandedSpy).toHaveBeenCalledWith(true);
        });
      });
    });
  });

  describe("setDisabled", () => {
    describe("when true", () => {
      beforeEach(() => {
        subject.expanderTarget.removeAttribute("disabled");

        subject.setDisabled(true);
      });

      it("sets disabled attribute", () => {
        expect(subject.expanderTarget.getAttribute("disabled")).toEqual("true");
      });

      it("sets aria-disabled to true", () => {
        expect(subject.expanderTarget.getAttribute("aria-disabled")).toEqual("true");
      });
    });

    describe("when false", () => {
      beforeEach(() => {
        subject.expanderTarget.setAttribute("disabled", true);

        subject.setDisabled(false);
      });

      it("removes disabled attribute", () => {
        expect(subject.expanderTarget.getAttribute("disabled")).toEqual(null);
      });

      it("sets aria-disabled to false", () => {
        expect(subject.expanderTarget.getAttribute("aria-disabled")).toEqual("false");
      });
    });
  });
});
