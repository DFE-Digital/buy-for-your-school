module Support
  #
  # Service to create
  #
  class CreateSupportCase
    # @param [support_enquiry][SupportEnquiry] SupportEnquiry Object

    def initialize(support_enquiry)
      @support_enquiry = support_enquiry
    end

    # @return [Support::Case]
    def call
      support_case = @support_enquiry.build_case
      support_case.save!
      support_case
    end

  private

    def attach_documents; end
  end
end
