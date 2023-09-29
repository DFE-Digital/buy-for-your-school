module CaseRequest::SchoolPickable
  extend ActiveSupport::Concern

  included do
    before_save :clear_school_urns, if: -> { attribute_changed?(:organisation_id) }
  end

  def school_picker(school_urns: self.school_urns)
    CaseRequest::SchoolPicker.new(case_request: self, school_urns:)
  end

  def pick_schools(school_urns)
    self.school_urns = school_urns
    save!
  end

  def selected_schools
    school_urns.map { |urn| Support::Organisation.find_by(urn:) }
  end

  def eligible_for_school_picker?
    return false unless organisation.is_a?(Support::EstablishmentGroup)

    organisation.eligible_for_school_picker?
  end

  def multischool?
    school_urns.present?
  end

private

  def clear_school_urns
    self.school_urns = []
  end
end
