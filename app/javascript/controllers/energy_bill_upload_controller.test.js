import EnergyBillUploadController from './energy_bill_upload_controller';

describe('EnergyBillUploadController', () => {

  const createField = (type, shouldShow = true) => {
    const field = document.createElement(type)

    if (!shouldShow)
      field.classList.add('govuk-!-display-none')

    return field
  }

  const createDropZone = ({
    anyFilesQueuedForUpload,
    anyFilesUploadedSuccessfully,
    anyFileUploadErrorsOccured
  } = {}) => {
    const dropZone = new DummyDropzoneController(
      anyFilesQueuedForUpload,
      anyFilesUploadedSuccessfully,
      anyFileUploadErrorsOccured
    )
    dropZone.filesAddedNowTarget = createField('div', false)
    dropZone.filesAddedNowTarget.appendChild(createField('h2'))
    dropZone.filesAddedBeforeTarget = createField('div', false)
    dropZone.filesAddedBeforeTarget.appendChild(createField('h2'))
    return dropZone
  }

  const expectToBeShown = (element) => expect(element).not.toHaveClass('govuk-!-display-none')
  const expectToBeHidden = (element) => expect(element).toHaveClass('govuk-!-display-none')

  class DummyDropzoneController {
    constructor(
      anyFilesQueuedForUpload = false,
      anyFilesUploadedSuccessfully = false,
      anyFileUploadErrorsOccured = false
    ) {
      this._anyFilesQueuedForUpload = anyFilesQueuedForUpload
      this._anyFilesUploadedSuccessfully = anyFilesUploadedSuccessfully
      this._anyFileUploadErrorsOccured = anyFileUploadErrorsOccured
    }

    anyFilesQueuedForUpload() { return this._anyFilesQueuedForUpload }
    anyFilesUploadedSuccessfully() { return this._anyFilesUploadedSuccessfully }
    anyFileUploadErrorsOccured() { return this._anyFileUploadErrorsOccured }
  }

  class DummyErrorSummaryController {
    addError(error) {}
    removeError(error) {}
  }

  let subject

  beforeEach(() => {
    subject = new EnergyBillUploadController()
    subject.titleTarget           = createField('h2', false)
    subject.lblHintTarget         = createField('p', false)
    subject.dropZoneTarget        = createField('div', false)
    subject.btnContinueTarget     = createField('button')
    subject.btnSubmitTarget       = createField('button')
    subject.btnAddMoreFilesTarget = createField('button')
    subject.dropzoneOutlet        = createDropZone()
    subject.errorSummaryOutlet    = new DummyErrorSummaryController()
    subject.pageOneTitleValue     = 'Page 1 Title'
    subject.pageTwoTitleValue     = 'Page 2 Title'
    subject.pageThreeTitleValue   = 'Page 3 Title'

    subject.errorSummaryOutletConnected(subject.errorSummaryOutlet)
  })

  describe('page one', () => {
    beforeEach(() => subject.pageOne())

    it('sets title to be the pageOneTitleValue', () => expect(subject.titleTarget).toHaveTextContent('Page 1 Title'))
    it('shows lblHintTarget', () => expectToBeShown(subject.lblHintTarget))
    it('shows dropZoneTarget', () => expectToBeShown(subject.dropZoneTarget))
    it('hides filesAddedNowTarget', () => expectToBeHidden(subject.dropzoneOutlet.filesAddedNowTarget))
    it('hides filesAddedNowTarget title', () => expectToBeHidden(subject.dropzoneOutlet.filesAddedNowTarget.querySelector('h2')))
    it('hides filesAddedBeforeTarget', () => expectToBeHidden(subject.dropzoneOutlet.filesAddedBeforeTarget))
    it('shows btnContinueTarget', () => expectToBeShown(subject.btnContinueTarget))
    it('hides btnSubmitTarget', () => expectToBeHidden(subject.btnSubmitTarget))
    it('hides btnAddMoreFilesTarget', () => expectToBeHidden(subject.btnAddMoreFilesTarget))
  })

  describe('page one (with files queued for upload)', () => {
    beforeEach(() => {
      subject.dropzoneOutlet = createDropZone({ anyFilesQueuedForUpload: true })
      subject.pageOne()
    })

    it('shows filesAddedNowTarget', () => expectToBeShown(subject.dropzoneOutlet.filesAddedNowTarget))
    it('shows filesAddedNowTarget title', () => expectToBeShown(subject.dropzoneOutlet.filesAddedNowTarget.querySelector('h2')))
  })

  describe('page one (with files uploaded already)', () => {
    beforeEach(() => {
      subject.dropzoneOutlet = createDropZone({ anyFilesUploadedSuccessfully: true })
      subject.pageOne()
    })

    it('shows filesAddedBeforeTarget', () => expectToBeShown(subject.dropzoneOutlet.filesAddedBeforeTarget))
    it('shows filesAddedBeforeTarget title', () => expectToBeShown(subject.dropzoneOutlet.filesAddedBeforeTarget.querySelector('h2')))
  })

  describe('page two', () => {
    beforeEach(() => subject.pageTwo())

    it('sets title to be the pageTwoTitleValue', () => expect(subject.titleTarget).toHaveTextContent('Page 2 Title'))
    it('hides lblHintTarget', () => expectToBeHidden(subject.lblHintTarget))
    it('hides dropZoneTarget', () => expectToBeHidden(subject.dropZoneTarget))
    it('shows filesAddedNowTarget', () => expectToBeShown(subject.dropzoneOutlet.filesAddedNowTarget))
    it('hides filesAddedNowTarget title', () => expectToBeHidden(subject.dropzoneOutlet.filesAddedNowTarget.querySelector('h2')))
    it('hides filesAddedBeforeTarget', () => expectToBeHidden(subject.dropzoneOutlet.filesAddedBeforeTarget))
    it('hides btnContinueTarget', () => expectToBeHidden(subject.btnContinueTarget))
    it('hides btnSubmitTarget', () => expectToBeHidden(subject.btnSubmitTarget))
    it('hides btnAddMoreFilesTarget', () => expectToBeHidden(subject.btnAddMoreFilesTarget))
  })

  describe('page three', () => {
    beforeEach(() => subject.pageThree())

    it('sets title to be the pageThreeTitleValue', () => expect(subject.titleTarget).toHaveTextContent('Page 3 Title'))
    it('hides lblHintTarget', () => expectToBeHidden(subject.lblHintTarget))
    it('hides dropZoneTarget', () => expectToBeHidden(subject.dropZoneTarget))
    it('shows filesAddedNowTarget', () => expectToBeShown(subject.dropzoneOutlet.filesAddedNowTarget))
    it('hides filesAddedNowTarget title', () => expectToBeHidden(subject.dropzoneOutlet.filesAddedNowTarget.querySelector('h2')))
    it('hides filesAddedBeforeTarget', () => expectToBeHidden(subject.dropzoneOutlet.filesAddedBeforeTarget))
    it('hides btnContinueTarget', () => expectToBeHidden(subject.btnContinueTarget))
    it('shows btnSubmitTarget', () => expectToBeShown(subject.btnSubmitTarget))
    it('shows btnAddMoreFilesTarget', () => expectToBeShown(subject.btnAddMoreFilesTarget))
  })

  describe('onDropzoneQueueComplete', () => {
    let continueToPageOneSpy, continueToPageThreeSpy

    beforeEach(() => {
      continueToPageOneSpy = jest.spyOn(subject, 'continueToPageOne').mockImplementation(() => {})
      continueToPageThreeSpy = jest.spyOn(subject, 'continueToPageThree').mockImplementation(() => {})
    })

    describe('when no files have been uploaded', () => {
      it('goes to page one (error has occurred)', () => {
        subject.onDropzoneQueueComplete({ totalEnqueuedFiles: 0, totalUploadedFiles: 0 })

        expect(continueToPageOneSpy).toHaveBeenCalledTimes(1)
        expect(continueToPageThreeSpy).not.toHaveBeenCalled()
      })
    })

    describe('when files are still enqueued', () => {
      it('goes to page one (error has occurred)', () => {
        subject.onDropzoneQueueComplete({ totalEnqueuedFiles: 1, totalUploadedFiles: 0 })

        expect(continueToPageOneSpy).toHaveBeenCalledTimes(1)
        expect(continueToPageThreeSpy).not.toHaveBeenCalled()
      })
    })

    describe('when all files have been uploaded', () => {
      it('goes to page three', () => {
        subject.onDropzoneQueueComplete({ totalEnqueuedFiles: 0, totalUploadedFiles: 1 })

        expect(continueToPageThreeSpy).toHaveBeenCalledTimes(1)
        expect(continueToPageOneSpy).not.toHaveBeenCalled()
      })
    })
  })

  describe('onDropzoneFileRemoved', () => {
    let pageOneSpy, continueToPageOneSpy

    beforeEach(() => {
      pageOneSpy = jest.spyOn(subject, 'pageOne').mockImplementation(() => {})
      continueToPageOneSpy = jest.spyOn(subject, 'continueToPageOne').mockImplementation(() => {})
    })

    describe('when on page 3', () => {
      beforeEach(() => subject.currentPage = 3)

      describe('when there are no more files that have been uploaded (all removed)', () => {
        beforeEach(() => subject.dropzoneOutlet = createDropZone({ anyFilesUploadedSuccessfully: false }))

        it('sends the user back to page 1', () => {
          subject.onDropzoneFileRemoved(undefined, 'Error')
          expect(continueToPageOneSpy).toHaveBeenCalledTimes(1)
        })
      })

      describe('when there are other files that have been uploaded already', () => {
        beforeEach(() => subject.dropzoneOutlet = createDropZone({ anyFilesUploadedSuccessfully: true }))

        it('does not automatically go to page 1', () => {
          subject.onDropzoneFileRemoved(undefined, 'Error')
          expect(continueToPageOneSpy).not.toHaveBeenCalled()
        })
      })
    })

    describe('when on page 1', () => {
      beforeEach(() => subject.currentPage = 1)

      it('re-renders page 1 to ensure details display correctly', () => {
        subject.onDropzoneFileRemoved(undefined, 'Error')
        expect(pageOneSpy).toHaveBeenCalledTimes(1)
      })
    })
  })

  describe('continueToPageOne', () => {
    describe('when we are returning back to page 1', () => {
      it('moves files from added section to previously uploaded', () => {
        const moveFilesFromAddedToAlreadyUploaded = jest
          .spyOn(subject, 'moveFilesFromAddedToAlreadyUploaded')
          .mockImplementation(() => {})

        subject.currentPage = 3
        subject.continueToPageOne()

        expect(moveFilesFromAddedToAlreadyUploaded).toHaveBeenCalledTimes(1)
      })
    })

    describe('when already on page 1', () => {
      it('doesnt need to move any files (errors have occurred)', () => {
        const moveFilesFromAddedToAlreadyUploaded = jest
          .spyOn(subject, 'moveFilesFromAddedToAlreadyUploaded')
          .mockImplementation(() => {})

        subject.currentPage = 1
        subject.continueToPageOne()

        expect(moveFilesFromAddedToAlreadyUploaded).not.toHaveBeenCalled()
      })
    })
  })

  describe('continueToPageTwo', () => {
    afterEach(jest.resetAllMocks)

    let errorSummarySpy
    beforeEach(() => { errorSummarySpy = jest.spyOn(subject.errorSummaryOutlet, 'addError')})

    describe('when an error has occurred but hasnt been fixed', () => {
      beforeEach(() => subject.dropzoneOutlet = createDropZone({ anyFileUploadErrorsOccured: true }))

      it('alerts the user to fix errors before they can move on', () => {
        subject.continueToPageTwo()
        expect(errorSummarySpy).toHaveBeenCalledWith('Please remove any invalid files marked in red')
      })
    })

    describe('when no files have been uploaded yet', () => {
      beforeEach(() => subject.dropzoneOutlet = createDropZone({ anyFilesUploadedSuccessfully: false }))

      it('alerts the user to choose files before they can move on', () => {
        subject.continueToPageTwo()
        expect(errorSummarySpy).toHaveBeenCalledWith('Please select one or more files to upload')
      })
    })

    describe('when no files have been queued for upload yet', () => {
      beforeEach(() => subject.dropzoneOutlet = createDropZone({ anyFilesQueuedForUpload: false }))

      it('alerts the user to choose files before they can move on', () => {
        subject.continueToPageTwo()
        expect(errorSummarySpy).toHaveBeenCalledWith('Please select one or more files to upload')
      })
    })

    describe('when no files have been queued for upload yet BUT files have previously been uploaded', () => {
      beforeEach(() => subject.dropzoneOutlet = createDropZone({ anyFilesQueuedForUpload: false, anyFilesUploadedSuccessfully: true }))

      it('sends the user back to page 3', () => {
        const continueToPageThreeSpy = jest.spyOn(subject, 'continueToPageThree').mockImplementation(() => {})

        subject.continueToPageTwo()

        expect(errorSummarySpy).not.toHaveBeenCalled()
        expect(continueToPageThreeSpy).toHaveBeenCalledTimes(1)
      })
    })

    describe('when files are enqueued', () => {
      beforeEach(() => subject.dropzoneOutlet = createDropZone({ anyFilesQueuedForUpload: true }))

      it('uploads them', () => {
        const uploadFilesSpy = jest.spyOn(subject, 'uploadFiles').mockImplementation(() => {})
        const continueToPageThreeSpy = jest.spyOn(subject, 'continueToPageThree').mockImplementation(() => {})

        subject.continueToPageTwo()

        expect(errorSummarySpy).not.toHaveBeenCalled()
        expect(continueToPageThreeSpy).not.toHaveBeenCalled()
        expect(uploadFilesSpy).toHaveBeenCalledTimes(1)
      })
    })
  })
});
