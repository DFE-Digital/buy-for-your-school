module Support
  class OrganisationPresenter < BasePresenter
    # @return [String] Combines URN and name
    def urn_and_name
      "#{urn} - #{name}"
    end

    # @return [String]
    def formatted_address
      [address["street"], address["locality"], address["postcode"]]
        .reject(&:blank?)
        .to_sentence(last_word_connector: ", ")
    end

    # @return [String, nil]
    def local_authority
      super["name"] if super
    end

    # @return [String]
    def contact
      "#{super['title']} #{super['first_name']} #{super['last_name']}" if super
    end

    # @return [String, nil]
    def phase
      super.to_s.humanize if super
    end
  end
end
