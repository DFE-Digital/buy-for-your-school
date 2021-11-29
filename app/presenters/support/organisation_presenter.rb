module Support
  class OrganisationPresenter < BasePresenter
    # @return [String]
    def formatted_address
      [address["street"], address["locality"], address["postcode"]]
        .reject(&:blank?)
        .to_sentence(last_word_connector: ", ")
    end
  end
end
