class Support::Case::EmailMover
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :source
  attribute :destination_id
  attribute :destination_type
  attribute :destination_ref

  validates :source, presence: true
  validates :destination_ref, presence: true
  validate :existing_destination, if: -> { destination_ref.present? }
  validate :matching_source_and_destination, if: -> { destination_ref.present? }

  def save!
    source.move_emails_to(ticket: destination)
  end

  def destination
    return if destination_id.blank? || destination_type.blank?

    destination_type.safe_constantize.find(destination_id)
  end

private

  def existing_destination
    # safe to assume the destination is selected from the autocomplete and exists if we've got both the id and type
    return if destination_id.present? && destination_type.present?

    errors.add(:destination_ref, "You must choose a valid case")
  end

  def matching_source_and_destination
    return if destination_ref != source.ref

    errors.add(:destination_ref, "You cannot merge into the same case")
  end
end
