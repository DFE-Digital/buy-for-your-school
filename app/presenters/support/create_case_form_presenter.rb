# frozen_string_literal: true

require_relative "concerns/has_organisation"

module Support
  class CreateCaseFormPresenter < RequestDetailsFormPresenter
    include Support::Concerns::HasOrganisation

    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end
  end
end
