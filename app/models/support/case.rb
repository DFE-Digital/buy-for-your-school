# TODO: replace this with an ActiveRecord model
# :nocov:
module Support
  class Case
    def self.all
      [find_by]
    end

    def self.find_by(_ignore = nil)
      OpenStruct.new(
        id: 1,
        
        # Enquiry
        organisation_name: 'St.Mary',
        email_address: 'hello@world.com',
        phone_number: '+44 777888999',
        query_text: 'Did anybody say Domino?',

        # Case
        category: Category.find_by(id: 1),
        sub_category: nil,
        state: 'new',
        status: nil,
        enquiry_text: nil,
        support_level: nil,
        enquiry_source: nil,
        participation_agreement_exists: false,
        created_at: 7.hours.ago,
        updated_at: 6.hours.ago,

        # Associations
        interactions: Interaction.all.map { |i| InteractionPresenter.new(i) },
        case_worker_account: CaseWorkerAccountPresenter.new(CaseWorkerAccount.find_by(id: 1)), 
        case_document: CaseDocumentPresenter.new(CaseDocument.find_by(id: 1)),
        cm_contact: CMContactPresenter.new(CMContact.find_by(id: 1)),

        created_at: 3.minutes.ago,
        updated_at: 2.minutes.ago
      )
    end
  end
end
# :nocov: