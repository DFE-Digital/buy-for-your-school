class Step < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :journey

  has_one :radio_answer
  has_one :short_text_answer
  has_one :long_text_answer
  has_one :single_date_answer
  has_one :checkbox_answers
  has_one :number_answer
  has_one :currency_answer

  scope :that_are_questions, -> { where(contentful_model: "question") }

  def answer
    @answer ||=
      radio_answer ||
      short_text_answer ||
      long_text_answer ||
      single_date_answer ||
      checkbox_answers ||
      number_answer ||
      currency_answer
  end

  def primary_call_to_action_text
    return I18n.t("generic.button.next") unless super.present?
    super
  end

  def help_text_html
    return unless help_text.present?
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(help_text).html_safe
  end
end
