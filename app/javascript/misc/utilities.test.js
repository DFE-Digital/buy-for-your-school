import { display } from "./utilities";

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
});
