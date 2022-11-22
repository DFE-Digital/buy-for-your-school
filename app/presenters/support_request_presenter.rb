# Helpers for a support request to display information on the page
class SupportRequestPresenter < RequestPresenter
  # @return [String] email address of user requesting support
  def email
    user&.email
  end

  # The name of the school that matches the chosen school URN
  #
  # @return [String] the name of the school
  def school_name
    user.supported_schools.find { |school| school.gias_id == school_urn }&.name
  end

  # return [JourneyPresenter, nil]
  def journey
    JourneyPresenter.new(super) if super.present?
  end

private

  def user
    UserPresenter.new(super)
  end
end
