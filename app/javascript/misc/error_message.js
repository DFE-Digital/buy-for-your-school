class ErrorMessage {
  constructor(errorSummaryOutlet, message) {
    this.errorSummaryOutlet = errorSummaryOutlet
    this.message = message
  }

  show() {
    this.errorSummaryOutlet.addError(this.message)
  }

  hide() {
    this.errorSummaryOutlet.removeError(this.message)
  }
}

export default ErrorMessage
