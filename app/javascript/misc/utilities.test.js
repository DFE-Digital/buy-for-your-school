import { display, enable } from "./utilities";

describe("Utilities", () => {
  describe("display", () => {
    let element;

    beforeEach(() => {
      element = document.createElement("div");
    });

    describe("when isVisible is true", () => {
      beforeEach(() => {
        element.classList.add("govuk-!-display-none");

        display(element, true);
      });

      it("removes the govuk-!-display-none class", () => {
        expect(element.classList.contains("govuk-!-display-none")).toEqual(false);
      });
    });

    describe("when isVisible is false", () => {
      beforeEach(() => {
        display(element, false);
      });

      it("adds the govuk-!-display-none class", () => {
        expect(element.classList.contains("govuk-!-display-none")).toEqual(true);
      });
    });
  });

  describe("enable", () => {
    let element;

    beforeEach(() => {
      element = document.createElement("input");
    });

    describe("when isEnabled is true", () => {
      beforeEach(() => {
        element.setAttribute("disabled", true);

        enable(element, true);
      });

      it("removes the disabled attribute", () => {
        expect(element.hasAttribute("disabled")).toEqual(false);
      });
    });

    describe("when isEnabled is false", () => {
      beforeEach(() => {
        enable(element, false);
      });

      it("sets the disabled attribute", () => {
        expect(element.hasAttribute("disabled")).toEqual(true);
      });
    });
  });
});
