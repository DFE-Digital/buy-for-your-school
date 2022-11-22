class UserPresenter < BasePresenter
  # @return [Array<JourneyPresenter>]
  def active_journeys
    journeys.initial.map { |j| JourneyPresenter.new(j) }
  end

  # @return [Boolean]
  def single_org?
    supported_orgs.one?
  end

  # @return [String, nil] inferred unique school identifier
  def school_urn
    supported_orgs.first.gias_id if single_org? && !supported_orgs.first.group
  end

  # @return [String, nil] inferred unique group identifier
  def group_uid
    supported_orgs.first.gias_id if single_org? && supported_orgs.first.group
  end

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

      OpenStruct.new(name: org["name"], gias_id: org["urn"], group: false)
    }.compact
  end

  # Support/FaF request form options when a single UID cannot be inferred
  #
  # @return [Array<OpenStruct>] the name/uid of a user's supported groups
  def supported_groups
    orgs.map { |org|
      next unless org.dig("category", "id").to_i.in?(GROUP_CATEGORY_IDS)

      OpenStruct.new(name: "#{org['name']} (MAT)", gias_id: org["uid"], group: true)
    }.compact
  end

  # FaF request form options (schools and trusts) when a single UID cannot be inferred
  #
  # @return [Array<OpenStruct>] the name/uid of a user's supported organisations
  def supported_orgs
    all_orgs = supported_schools + supported_groups
    all_orgs.sort_by(&:name)
  end

  # @return [String]
  def full_name
    super || "#{first_name} #{last_name}"
  end
end
