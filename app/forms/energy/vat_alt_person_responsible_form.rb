class Energy::VatAltPersonResponsibleForm < Energy::Form
  option :organisation
  option :vat_alt_person_first_name, Types::Params::String, optional: true
  option :vat_alt_person_last_name, Types::Params::String, optional: true
  option :vat_alt_person_phone, Types::Params::String, optional: true
  option :vat_alt_person_address, Types::Params::Hash, optional: true

  def vat_alt_address_options
    return {} if organisation.trust_code.blank?

    @vat_alt_address_options ||= {
      org_address: {
        short: Support::OrganisationPresenter.new(organisation)&.formatted_address,
        full: organisation.address,
      },
      group_address: {
        short: Support::EstablishmentGroupPresenter.new(establishment_group)&.formatted_address,
        full: establishment_group.address,
      },
    }
  end

private

  def establishment_group
    @establishment_group ||= Support::EstablishmentGroup.find_by(uid: organisation.trust_code)
  end
end
