class FrameworkRequestPresenter < RequestPresenter
  # @return [UserPresenter, OpenStruct]
  def user
    if user_id
      UserPresenter.new(super)
    else
      OpenStruct.new(
        email:,
        first_name:,
        last_name:,
        full_name: "#{first_name} #{last_name}",
      )
    end
  end

  # @return [Boolean]
  def dsi?
    user_id.present?
  end

  # TODO: extract into a look-up service rather than access supported data directly
  def org_name
    return I18n.t("support.case_categorisations.label.none") unless organisation

    organisation.name
  end

  # TODO: extract into a look-up service rather than access supported data directly
  def group_type
    organisation&.establishment_group_type&.name
  end

  def bill_count
    energy_bills.count
  end

  def bill_filenames
    energy_bills.map(&:filename).join(", ")
  end
end
