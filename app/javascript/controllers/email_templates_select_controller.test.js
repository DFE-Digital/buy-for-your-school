import EmailTemplatesSelectController from "./email_templates_select_controller";

describe("EmailTemplatesSelectController", () => {
  let subject;

  beforeEach(() => {
    subject = new EmailTemplatesSelectController();
    subject.btnUseTemplateTarget = document.createElement("input");
  });

  describe("onTemplateSelected", () => {
    beforeEach(() => {
      subject.btnUseTemplateTarget.setAttribute("disabled", "disabled");

      subject.onTemplateSelected(null);
    });

    it("removes the 'disabled' attribute from the input", () => {
      expect(subject.btnUseTemplateTarget.getAttribute("disabled")).toBeNull();
    });
  });
});
