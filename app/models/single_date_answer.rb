# SingleDateAnswer is used to capture a single date answer to a {Step}.
class SingleDateAnswer < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response,
            presence: {
              message: I18n.t("activerecord.errors.models.single_date_answer.attributes.response"),
            }
end
