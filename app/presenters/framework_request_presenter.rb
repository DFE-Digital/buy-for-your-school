class FrameworkRequestPresenter < BasePresenter
  # TODO: extract into a look-up service rather than access supported data directly
  # @return [String]
  def school_name
    Support::Organisation.find_by(urn: school_urn)&.name || "n/a"
  end

  # @return [UserPresenter, OpenStruct]
  def user
    if user_id
      UserPresenter.new(super)
    else
      OpenStruct.new(
        email: email,
        first_name: first_name,
        last_name: last_name,
        full_name: "#{first_name} #{last_name}",
      )
    end
  end

  # @return [Boolean]
  def dsi?
    user_id.present?
  end

  # :nocov:
  # TODO: extract into a look-up service rather than access supported data directly
  def group_name
    return I18n.t("support.case_categorisations.label.none") if group_uid.blank?

    Support::EstablishmentGroup.find_by(uid: group_uid).name
  end

  # TODO: extract into a look-up service rather than access supported data directly
  def group_type
    return I18n.t("support.case_categorisations.label.none") if group_uid.blank?

    group_type_id = Support::EstablishmentGroup.find_by(uid: group_uid).establishment_group_type_id
    @group_type_name = Support::EstablishmentGroupType.where(id: group_type_id).first.name
  end
  # :nocov:
end
