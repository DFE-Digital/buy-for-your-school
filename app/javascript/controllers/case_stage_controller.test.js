import CaseStageController from "./case_stage_controller";

describe("CaseStageController", () => {
  const utilities = jest.requireActual("../misc/utilities");
  let subject;
  let displaySpy;
  let enableSpy;

  beforeEach(() => {
    subject = new CaseStageController();
    subject.procurementStageTarget = document.createElement("select");
    const optionNeed = document.createElement("option");
    optionNeed.textContent = "Need";
    const optionOther = document.createElement("option");
    optionOther.textContent = "Other";
    subject.procurementStageTarget.replaceChildren(optionNeed, optionOther);
    subject.procurementStageWrapperTarget = document.createElement("div");

    displaySpy = jest.spyOn(utilities, "display").mockImplementation(() => {});
    enableSpy = jest.spyOn(utilities, "enable").mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe("showProcurementStage", () => {
    it("calls display with true", () => {
      subject.showProcurementStage();
      expect(displaySpy).toHaveBeenCalledWith(subject.procurementStageWrapperTarget, true);
    });

    describe("when a procurement stage is not selected", () => {
      beforeEach(() => {
        subject.procurementStageTarget.value = null;
      });

      it("selects the first option", () => {
        subject.showProcurementStage();
        expect(subject.procurementStageTarget.selectedIndex).toEqual(0);
      });
    });
  });

  describe("hideProcurementStage", () => {
    beforeEach(() => {
      subject.hideProcurementStage();
    });

    it("calls display with false", () => {
      expect(displaySpy).toHaveBeenCalledWith(subject.procurementStageWrapperTarget, false);
    });

    it("sets the procurement stage value to be blank", () => {
      subject.hideProcurementStage();
      expect(subject.procurementStageTarget.value).toEqual("");
    });
  });

  describe("toggleProcurementStageEnabled", () => {
    describe("when the support level is 4", () => {
      let e = { target: { value: "L4" } };

      beforeEach(() => {
        subject.procurementStageTarget.setAttribute("disabled", true);
  
        subject.toggleProcurementStageEnabled(e);
      });

      it("calls enable with true", () => {
        expect(enableSpy).toHaveBeenCalledWith(subject.procurementStageTarget, true);
      });
    });

    describe("when the support level is 5", () => {
      let e = { target: { value: "L5" } };

      beforeEach(() => {
        subject.procurementStageTarget.setAttribute("disabled", true);
  
        subject.toggleProcurementStageEnabled(e);
      });

      it("calls enable with true", () => {
        expect(enableSpy).toHaveBeenCalledWith(subject.procurementStageTarget, true);
      });
    });

    describe("when the support level is 6", () => {
      let e = { target: { value: "L6" } };

      beforeEach(() => {
        subject.procurementStageTarget.setAttribute("disabled", true);
  
        subject.toggleProcurementStageEnabled(e);
      });

      it("calls enable with true", () => {
        expect(enableSpy).toHaveBeenCalledWith(subject.procurementStageTarget, true);
      });
    });

    describe("when the support level is 7", () => {
      let e = { target: { value: "L7" } };

      beforeEach(() => {
        subject.procurementStageTarget.setAttribute("disabled", true);
  
        subject.toggleProcurementStageEnabled(e);
      });

      it("calls enable with true", () => {
        expect(enableSpy).toHaveBeenCalledWith(subject.procurementStageTarget, true);
      });
    });

    describe("when the support level is something else", () => {
      let e = { target: { value: "L3" } };

      beforeEach(() => {
        subject.procurementStageTarget.removeAttribute("disabled");
  
        subject.toggleProcurementStageEnabled(e);
      });

      it("calls enable with false", () => {
        expect(enableSpy).toHaveBeenCalledWith(subject.procurementStageTarget, false);
      });

      it("selects the first option", () => {
        expect(subject.procurementStageTarget.selectedIndex).toEqual(0);
      });
    });
  });

  describe("enableProcurementStageElement", () => {
    beforeEach(() => {
      subject.enableProcurementStageElement();
    });

    it("calls enable with true", () => {
      expect(enableSpy).toHaveBeenCalledWith(subject.procurementStageTarget, true);
    });
  });
});
