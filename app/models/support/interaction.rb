# TODO: replace this with an ActiveRecord model
# :nocov:
module Support
  class Interaction
    def self.all
      [find_by]
    end

    def self.find_by(_ignore = nil)
      OpenStruct.new(
        id: 1,
        author: 'Cassius Clay',
        type: 'Phone',
        note: 'Ticket was submitted correctly',

        # Associations
        case: -> { CasePresenter.new(Case.find_by(id: 1)) },

        created_at: 3.minutes.ago,
        updated_at: 2.minutes.ago
      )
    end
  end
end
# :nocov:
