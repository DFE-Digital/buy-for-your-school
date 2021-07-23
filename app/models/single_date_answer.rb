# Persist {Step} response for questions of type 'single_date'
#
class SingleDateAnswer < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response,
            presence: {
              message: I18n.t("activerecord.errors.models.single_date_answer.attributes.response"),
            }

  validates_with RangeValidator
end
