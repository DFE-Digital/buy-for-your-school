module AddressHelper
  def format_address(address_hash)
  [
    address_hash["street"],
    address_hash["locality"],
    address_hash["town"],
    address_hash["county"],
    address_hash["postcode"],
  ]
    .reject(&:blank?)
    .to_sentence(last_word_connector: ", ", two_words_connector: ", ")
    .presence || I18n.t("generic.not_provided")
  end
end
