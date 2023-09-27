module Support::Case::SchoolPickable
  extend ActiveSupport::Concern

  def school_picker(school_urns: participating_schools.map(&:urn))
    Support::Case::SchoolPicker.new(support_case: self, school_urns:)
  end

  def pick_schools(school_urns)
    schools = Support::Organisation.where(urn: school_urns)
    self.participating_schools = schools
    save!
  end
end
