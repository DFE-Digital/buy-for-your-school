class Step < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :journey

  has_one :radio_answer
  has_one :short_text_answer
  has_one :long_text_answer
  has_one :single_date_answer
  has_one :checkbox_answers

  def answer
    @answer ||=
      radio_answer ||
      short_text_answer ||
      long_text_answer ||
      single_date_answer ||
      checkbox_answers
  end

  def primary_call_to_action_text
    return I18n.t("generic.button.next") unless super.present?
    super
  end
end
