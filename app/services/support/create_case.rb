module Support
  #
  # Service to open Case from Enquiry
  #
  class CreateCase
    # @param enquiry [Enquiry] incoming request for support

    def initialize(enquiry)
      @enquiry = enquiry
    end

    # @return [Support::Case]
    def call
      kase = @enquiry.build_case
      attach_documents
      kase.save!
      kase
    end

  private

    # Change the association of the documents from SupportEnquiry to SupportCase (polymorphic)
    # @return [Array<Documents>]
    def attach_documents
      @enquiry.documents.each do |doc|
        doc.documentable = @enquiry.case
      end
    end
  end
end
