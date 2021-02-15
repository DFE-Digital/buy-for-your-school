class SingleDateAnswer < ActiveRecord::Base
  self.implicit_order_column = "created_at"
  belongs_to :step

  validates :response, presence: {message: I18n.t("activerecord.errors.models.single_date_answer.attributes.response")}
end
