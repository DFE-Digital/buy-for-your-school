class UserPresenter < SimpleDelegator
  # @return [Array<JourneyPresenter>]
  def active_journeys
    journeys.initial.map { |j| JourneyPresenter.new(j) }
  end

  # Get all organisations supported for selection
  #
  # @return [UserPresenter::SupportedOrganisation] supported organisations
  def supported_schools
    return [] unless valid_supported_orgs.any?

    valid_supported_orgs.map { |org| OpenStruct.new(**org.symbolize_keys) }
  end

  # @return [String]
  def full_name
    super || "#{first_name} #{last_name}"
  end

private

  def organisations
    Array(orgs)
  end

  # return only organisations that have a name, urn and the org type id
  # appears in ORG_TYPE_IDS constant
  def valid_supported_orgs
    @valid_supported_orgs ||= organisations.select do |data|
      type_id = data.dig("type", "id")
      name = data["name"]
      urn = data["urn"]

      name.present? && urn.present? && type_id.to_i.in?(ORG_TYPE_IDS)
    end
  end
end
