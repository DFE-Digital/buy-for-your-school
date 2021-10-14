# Helpers to aid in getting a user's supported schools
# and other things to do with schools
module SchoolsHelper
  # Get all schools supported for selection
  #
  # @return [GetSupportedSchoolsForUser::School] supported schools
  def supported_schools_collection
    GetSupportedSchoolsForUser.new(user: current_user).call
  end

  # The name of the school that matches the given URN or "None"
  #
  # @param [String|nil] urn The urn of the school you want a name for
  #
  # @return [String] the name of the school or None
  def school_name_for_urn_or_none(urn)
    return "None" if urn == "none" || urn.blank?

    found_school = supported_schools_collection
      .find { |school| school.urn == urn }

    found_school&.name || "None"
  end
end
