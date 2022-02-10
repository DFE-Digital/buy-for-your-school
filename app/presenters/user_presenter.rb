class UserPresenter < BasePresenter
  # @return [Array<JourneyPresenter>]
  def active_journeys
    journeys.initial.map { |j| JourneyPresenter.new(j) }
  end

  # @return [String, nil] inferred unique school identifier
  def school_urn
    supported_schools.first.urn if supported_schools.one?
  end

  # TODO - ref for ticket 231
  # # @return [String, nil] inferred unique school identifier
  # def group_uid
  #   supported_groups.first.uid if supported_groups.one?
  # end

  # @return [String, nil] inferred school name
  # def school_name
  #   supported_schools.first.name if supported_schools.one?
  # end

  # Support request form options when a single URN cannot be inferred
  # @see support_requests/form/step2
  #
  # @return [Array<OpenStruct>] the name/urn of a user's supported schools
  def supported_schools
    orgs.map { |org|
      next unless org.dig("type", "id").to_i.in?(ORG_TYPE_IDS)

      OpenStruct.new(name: org["name"], urn: org["urn"])
    }.compact
  end

  # TODO - ref for ticket 231
  # def supported_groups
  #   orgs.map { |org|
  #     next unless org.dig("category", "id").to_i.in?(GROUP_CATEGORY_IDS)

  #     OpenStruct.new(name: org["name"], uid: org["uid"])
  #   }.compact
  # end

  # @return [String]
  def full_name
    super || "#{first_name} #{last_name}"
  end
end
