# Site Contact Details Form
#
class Energy::SiteContactDetailsForm < Energy::Form
  # @!attribute [r] site_contact_first_name
  # @return [String]
  option :site_contact_first_name, optional: true

  # @!attribute [r] site_contact_last_name
  # @return [String]
  option :site_contact_last_name, optional: true

  # @!attribute [r] site_contact_email
  # @return [String]
  option :site_contact_email, optional: true

  # @!attribute [r] site_contact_phone
  # @return [String]
  option :site_contact_phone, optional: true
end
