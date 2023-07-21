import CaseSummaryController from "./case_summary_controller";

describe("CaseSummaryController", () => {
  let subject;
  let requestTypeOutlet;
  let caseStageOutlet;

  beforeEach(() => {
    subject = new CaseSummaryController();
    caseStageOutlet = {
      enableProcurementStageElement: jest.fn(() => {}),
      showProcurementStage: jest.fn(() => {}),
      hideProcurementStage: jest.fn(() => {}),
    };
    requestTypeOutlet = {
      isProcurementRadioChecked: jest.fn(() => {}),
      setupOnProcurementSelected: jest.fn(() => {}),
      setupOnNonProcurementSelected: jest.fn(() => {}),
    };
    subject.caseStageOutlet = caseStageOutlet;
    subject.requestTypeOutlet = requestTypeOutlet;
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe("caseStageOutletConnected", () => {
    describe("when the RequestType outlet is already connected", () => {
      beforeEach(() => {
        subject.hasRequestTypeOutlet = true;
      });

      describe("when isProcurementRadioChecked on RequestType outlet returns true", () => {
        beforeEach(() => {
          requestTypeOutlet.isProcurementRadioChecked = jest.fn(() => true);
          subject.caseStageOutletConnected(caseStageOutlet);
        });

        it("calls showProcurementStage on CaseStage outlet", () => {
          expect(caseStageOutlet.showProcurementStage).toHaveBeenCalledTimes(1);
        });
      });

      describe("when isProcurementRadioChecked on RequestType outlet returns false", () => {
        beforeEach(() => {
          requestTypeOutlet.isProcurementRadioChecked = jest.fn(() => false);
          subject.caseStageOutletConnected(caseStageOutlet);
        });

        it("calls hideProcurementStage on CaseStage outlet", () => {
          expect(caseStageOutlet.hideProcurementStage).toHaveBeenCalledTimes(1);
        });
      });
    });
  });

  describe("requestTypeOutletConnected", () => {
    beforeEach(() => {
      subject.requestTypeOutletConnected(requestTypeOutlet);
    });

    it("sets the setupOnProcurementSelected callback on RequestType outlet", () => {
      expect(requestTypeOutlet.setupOnProcurementSelected).toHaveBeenCalledTimes(1);
    })

    it("sets the setupOnNonProcurementSelected callback on RequestType outlet", () => {
      expect(requestTypeOutlet.setupOnNonProcurementSelected).toHaveBeenCalledTimes(1);
    })
  });

  describe("onProcurementSelected", () => {
    beforeEach(() => {
      subject.onProcurementSelected();
    });

    it("calls showProcurementStage on CaseStage outlet", () => {
      expect(caseStageOutlet.showProcurementStage).toHaveBeenCalledTimes(1);
    });
  });

  describe("onNonProcurementSelected", () => {
    beforeEach(() => {
      subject.onNonProcurementSelected();
    });

    it("calls hideProcurementStage on CaseStage outlet", () => {
      expect(caseStageOutlet.hideProcurementStage).toHaveBeenCalledTimes(1);
    });
  });

  describe("submit", () => {
    beforeEach(() => {
      subject.submit();
    });

    it("calls enableProcurementStageElement on CaseStage outlet", () => {
      expect(caseStageOutlet.enableProcurementStageElement).toHaveBeenCalledTimes(1);
    });
  });
});
