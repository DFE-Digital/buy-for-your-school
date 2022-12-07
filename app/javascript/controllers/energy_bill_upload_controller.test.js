import EnergyBillUploadController from './energy_bill_upload_controller';
import { Application } from '@hotwired/stimulus';

describe('EnergyBillUploadController', () => {
  beforeAll(() => {
    window.Stimulus = Application.start();
    Stimulus.register('energy-bill-upload', EnergyBillUploadController);
  });

  beforeEach(() => {
    document.body.innerHTML = `
      <div
        data-controller="energy-bill-upload"
        data-energy-bill-upload-page-one-title-value="Upload your energy information"
        data-energy-bill-upload-page-one-continue-button-value="Continue to upload"
        data-energy-bill-upload-page-two-title-value="Your files are uploading"
        data-energy-bill-upload-page-two-continue-button-value="Continue to upload"
        data-energy-bill-upload-page-three-title-value="Your files have been uploaded"
        data-energy-bill-upload-page-three-continue-button-value="Continue">

        <button id="btn-continue"
          class="govuk-button"
          data-action="click->energy-bill-upload#onContinueToUploadClicked"
          data-energy-bill-upload-target="btnContinue">
          Continue to upload
        </button>
      </div>
    `;
  });

  it('sample test to check jest framework', () => {
    const el = document.querySelector('[data-controller="energy-bill-upload"]');
    expect(el).toHaveTextContent('Continue to upload');
  });
});
