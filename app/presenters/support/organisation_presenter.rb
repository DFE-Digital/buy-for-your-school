module Support
  class OrganisationPresenter < BasePresenter
    # @return [String]
    def formatted_address
      [address["street"], address["locality"], address["postcode"]]
        .reject(&:blank?)
        .to_sentence(last_word_connector: ", ")
    end

    # @return [String]
    def local_authority
      super["name"]
    end

    # @return [String]
    def contact
      "#{super['title']} #{super['first_name']} #{super['last_name']}"
    end

    # @return [String]
    def phase
      super.to_s.humanize
    end
  end
end
