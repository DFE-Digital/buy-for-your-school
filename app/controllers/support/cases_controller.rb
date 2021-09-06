# TODO: remove and use ActiveRecord resources instead
# :nocov:
module Support
  class Case
    def self.all
      [find_by(1)]
    end

    def self.find_by(_ignore)
      time = Time.zone.local(2020, 1, 30, 12)

      OpenStruct.new(
        id: 1,

        # Enquiry
        organisation_name: "St.Mary",
        email_address: "hello@world.com",
        phone_number: "+44 777888999",
        query_text: "Did anybody say Domino?",

        # Case
        sub_category: nil,
        state: "new",
        status: nil,
        enquiry_text: nil,
        support_level: nil,
        enquiry_source: nil,
        participation_agreement_exists: false,
        created_at: time,
        updated_at: time,

        # Associations
        category: OpenStruct.new(
          id: 1,
          name: "Catering",
        ),
        interactions: [
          OpenStruct.new(
            id: 1,
            author: "Cassius Clay",
            type: "Phone",
            note: "Ticket was submitted correctly",
            created_at: time,
            updated_at: time,
          ),
        ],
        case_worker_account: OpenStruct.new(
          id: 1,
          name: "Dracula",
          email_address: "fast@and.furious",
        ),
        case_document: OpenStruct.new(
          id: 1,
          file_name: nil,
          file_location: nil,
          file_type: nil,
          file_content_type: nil,
          document_body: nil,
        ),
        contact: OpenStruct.new(
          id: 1,
          first_name: "John",
          last_name: "Wick",
          email_address: "john@wick.com",
          phone_number: "+44 777888999",
          digital_account_id: 1,
        ),
      )
    end
  end
end
# :nocov:

module Support
  class CasesController < ApplicationController
    def index
      @cases = Support::Case.all.map { |c| CasePresenter.new(c) }
    end

    def show
      c = Support::Case.find_by(id: params[:id])

      @case = CasePresenter.new(c)
    end
  end
end
