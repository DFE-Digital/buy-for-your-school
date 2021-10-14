class UserPresenter < SimpleDelegator
  # @return [Array<JourneyPresenter>]
  def active_journeys
    journeys.initial.map { |j| JourneyPresenter.new(j) }
  end

  # Get all schools supported for selection
  #
  # @return [GetSupportedSchoolsForUser::School] supported schools
  def supported_schools
    GetSupportedSchoolsForUser.new(user: self).call
  end

# @return [String]
  def full_name
    super || "#{first_name} #{last_name}"
  end
end
