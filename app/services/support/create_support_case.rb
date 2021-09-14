module Support
  #
  # Service to create SupportCases from SupportEnquiry
  #
  class CreateSupportCase
    # @param [support_enquiry][SupportEnquiry] SupportEnquiry Object

    def initialize(support_enquiry)
      @support_enquiry = support_enquiry
    end

    # @return [Support::Case]
    def call
      support_case = @support_enquiry.build_case
      attach_documents
      support_case.save!
      support_case
    end

  private

    # Change the association of the documents from SupportEnquiry to SupportCase (polymorphic)
    # @return [Array][Support::Documents]
    def attach_documents
      @support_enquiry.documents.each do |doc|
        doc.documentable = @support_enquiry.case
      end
    end
  end
end
