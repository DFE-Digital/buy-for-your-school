import CaseQuickEditController from "./case_quick_edit_controller";

describe("CaseQuickEditController", () => {
  let subject;
  let caseStageOutlet;

  beforeEach(() => {
    subject = new CaseQuickEditController();
    caseStageOutlet = {
      enableProcurementStageElement: jest.fn(() => {}),
      showProcurementStage: jest.fn(() => {}),
      hideProcurementStage: jest.fn(() => {}),
    };
    subject.caseStageOutlet = caseStageOutlet;
  });

  describe("caseStageOutletConnected", () => {
    describe("when showProcurementStageValue is true", () => {
      beforeEach(() => {
        subject.showProcurementStageValue = true;
        subject.caseStageOutletConnected(caseStageOutlet);
      });

      it("calls showProcurementStage on the CaseStage outlet", () => {
        expect(caseStageOutlet.showProcurementStage).toHaveBeenCalledTimes(1);
      });
    });

    describe("when showProcurementStageValue is false", () => {
      beforeEach(() => {
        subject.showProcurementStageValue = false;
        subject.caseStageOutletConnected(caseStageOutlet);
      });

      it("calls hideProcurementStage on the CaseStage outlet", () => {
        expect(caseStageOutlet.hideProcurementStage).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe("submit", () => {
    beforeEach(() => {
      subject.submit();
    });

    it("calls enableProcurementStageElement on the CaseStage outlet", () => {
      expect(caseStageOutlet.enableProcurementStageElement).toHaveBeenCalledTimes(1);
    });
  });
});
