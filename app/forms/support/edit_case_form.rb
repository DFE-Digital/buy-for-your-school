# frozen_string_literal: true

module Support
  class EditCaseForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :request_text, optional: true

    # @return [Hash] form params as request attributes
    def to_h
      self.class.dry_initializer.attributes(self).except(:messages)
    end
  end
end
