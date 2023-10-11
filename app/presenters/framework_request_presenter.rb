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
    return I18n.t("support.case_categorisations.label.none") if org_id.blank?

    if group
      Support::EstablishmentGroup.find_by(uid: org_id)&.name
    else
      Support::Organisation.find_by(urn: org_id)&.name
    end
  end

  def org_name_or_number
    return I18n.t("support.case_categorisations.label.none") if org_id.blank?

    if group && school_urns.present?
      "#{school_urns.count} out of #{organisation.organisations.count} schools"
    else
      org_name
    end
  end

  # TODO: extract into a look-up service rather than access supported data directly
  def group_type
    group_type_id = Support::EstablishmentGroup.find_by(uid: org_id)&.establishment_group_type_id
    @group_type_name = Support::EstablishmentGroupType.where(id: group_type_id)&.first&.name
  end

  def bill_count
    energy_bills.count
  end

  def bill_filenames
    return if energy_bills.empty?

    energy_bills.map(&:filename).join(", ")
  end

  def document_count
    documents.count
  end

  def document_filenames
    return if documents.empty?

    documents.map(&:filename).join(", ")
  end

  def contract_length
    return if super.nil?

    I18n.t("faf.contract_length.options.#{super}")
  end

  def contract_start_date
    return if super.nil?

    super.strftime(date_format)
  end

  def same_supplier_used
    return if super.nil?

    I18n.t("faf.same_supplier.options.#{super}")
  end

  def origin
    return if super.nil?
    return origin_other if origin_other?

    I18n.t("faf.origin.options.#{super}")
  end
end
