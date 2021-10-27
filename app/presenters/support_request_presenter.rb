# Provide formatted versions of support request fields for views
#
class SupportRequestPresenter < SimpleDelegator
  # The name of the school that matches the chosen school URN
  #
  # @return [String] the name of the school
  def selected_school
    found_school = user.supported_schools.find { |school| school.urn == school_urn }
    found_school&.name || "None"
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
