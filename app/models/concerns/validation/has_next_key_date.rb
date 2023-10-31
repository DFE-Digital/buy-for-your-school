module Validation::HasNextKeyDate
  extend ActiveSupport::Concern

  included do
    validate :next_key_date_valid
    validates :next_key_date, presence: true, if: -> { next_key_date_description.present? }
  end

private

  def next_key_date_valid
    return if next_key_date.is_a?(Date) || next_key_date.blank?

    begin
      self.next_key_date = Date.civil(next_key_date["year"].to_i, next_key_date["month"].to_i, next_key_date["day"].to_i)
    rescue Date::Error, TypeError
      errors.add(:next_key_date, I18n.t("support.case_summary.invalid_date"))
    end
  end
end
