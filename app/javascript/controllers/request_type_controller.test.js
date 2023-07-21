import RequestTypeController from "./request_type_controller";

describe("RequestTypeController", () => {
  let subject;

  beforeEach(() => {
    subject = new RequestTypeController();
    subject.procurementRadioTarget = document.createElement("input");
  });

  describe("setupOnProcurementSelected", () => {
    beforeEach(() => {
      subject.setupOnProcurementSelected("callback");
    });

    it("sets the onProcurementSelectedCallback", () => {
      expect(subject.onProcurementSelectedCallback).toEqual("callback");
    });
  });

  describe("setupOnNonProcurementSelected", () => {
    beforeEach(() => {
      subject.setupOnNonProcurementSelected("callback");
    });

    it("sets the onNonProcurementSelectedCallback", () => {
      expect(subject.onNonProcurementSelectedCallback).toEqual("callback");
    });
  });

  describe("procurementSelected", () => {
    beforeEach(() => {
      subject.onProcurementSelectedCallback = jest.fn(() => {});
      subject.procurementSelected("event");
    });

    it("calls onProcurementSelectedCallback", () => {
      expect(subject.onProcurementSelectedCallback).toHaveBeenCalledWith("event");
    });
  });

  describe("nonProcurementSelected", () => {
    beforeEach(() => {
      subject.onNonProcurementSelectedCallback = jest.fn(() => {});
      subject.nonProcurementSelected("event");
    });

    it("calls onNonProcurementSelectedCallback", () => {
      expect(subject.onNonProcurementSelectedCallback).toHaveBeenCalledWith("event");
    });
  });

  describe("isProcurementRadioChecked", () => {
    beforeEach(() => {
      subject.procurementRadioTarget.checked = true;
    });

    it("returns the 'checked' value of procurementRadioTarget", () => {
      expect(subject.isProcurementRadioChecked()).toEqual(true);
    });
  });
});
