module AddressHelper
  def format_address(address_hash)
    return "" if address_hash.blank?

    %w[street locality town county postcode].map { |key|
      address_hash[key].presence unless address_hash[key] == "Not recorded"
    }.compact.join(", ")
  end
end
