import CaseProcurementController from "./case_procurement_controller";

describe("CaseProcurementController", () => {
  let subject;
  const utilities = jest.requireActual("../misc/utilities");

  beforeEach(() => {
    subject = new CaseProcurementController();
    subject.procurementRadioTarget = document.createElement("input");
    subject.nonProcurementRadioTarget = document.createElement("input");
    subject.procurementStageTarget = document.createElement("select");
    const optionNeed = document.createElement("option");
    optionNeed.textContent = "Need";
    const optionOther = document.createElement("option");
    optionOther.textContent = "Other";
    subject.procurementStageTarget.replaceChildren(optionNeed, optionOther);
    subject.procurementStageWrapperTarget = document.createElement("div");
  });

  describe("connect", () => {
    describe("when the procurement radio button is checked", () => {
      let showProcurementStageSpy;

      beforeEach(() => {
        subject.procurementRadioTarget.checked = true;
        showProcurementStageSpy = jest.spyOn(subject, "showProcurementStage").mockImplementation(() => {});

        subject.connect();
      });

      it("calls showProcurementStage", () => {
        expect(showProcurementStageSpy).toHaveBeenCalledTimes(1);
      });
    });

    describe("when the procurement radio button is not checked", () => {
      let hideProcurementStageSpy;

      beforeEach(() => {
        subject.procurementRadioTarget.checked = false;
        hideProcurementStageSpy = jest.spyOn(subject, "hideProcurementStage").mockImplementation(() => {});

        subject.connect();
      });

      it("calls hideProcurementStage", () => {
        expect(hideProcurementStageSpy).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe("showProcurementStage", () => {
    let displaySpy;

    beforeEach(() => {
      displaySpy = jest.spyOn(utilities, "display").mockImplementation(() => {});
    });

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
    let displaySpy;

    beforeEach(() => {
      displaySpy = jest.spyOn(utilities, "display").mockImplementation(() => {});

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

      it("removes the disabled attribute from the procurement stage", () => {
        expect(subject.procurementStageTarget.hasAttribute("disabled")).toEqual(false);
      });
    });

    describe("when the support level is 5", () => {
      let e = { target: { value: "L5" } };

      beforeEach(() => {
        subject.procurementStageTarget.setAttribute("disabled", true);
  
        subject.toggleProcurementStageEnabled(e);
      });

      it("removes the disabled attribute from the procurement stage", () => {
        expect(subject.procurementStageTarget.hasAttribute("disabled")).toEqual(false);
      });
    });

    describe("when the support level is something else", () => {
      let e = { target: { value: "L3" } };

      beforeEach(() => {
        subject.procurementStageTarget.removeAttribute("disabled");
  
        subject.toggleProcurementStageEnabled(e);
      });

      it("sets the disabled attribute on the procurement stage", () => {
        expect(subject.procurementStageTarget.hasAttribute("disabled")).toEqual(true);
      });

      it("selects the first option", () => {
        expect(subject.procurementStageTarget.selectedIndex).toEqual(0);
      });
    });
  });

  describe("submit", () => {
    beforeEach(() => {
      subject.procurementStageTarget.setAttribute("disabled", true);

      subject.submit();
    });

    it("removes the disabled attribute from the procurement stage", () => {
      expect(subject.procurementStageTarget.hasAttribute("disabled")).toEqual(false);
    });
  });
});
