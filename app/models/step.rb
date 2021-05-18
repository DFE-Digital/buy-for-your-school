class Step < ApplicationRecord
  self.implicit_order_column = "order"
  default_scope { order(:order) }

  belongs_to :task

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
      case contentful_type
      when "radios" then radio_answer
      when "short_text" then short_text_answer
      when "long_text" then long_text_answer
      when "single_date" then single_date_answer
      when "checkboxes" then checkbox_answers
      when "number" then number_answer
      when "currency" then currency_answer
      end
  end

  def answered?
    !answer.nil?
  end

  def primary_call_to_action_text
    return I18n.t("generic.button.next") unless super.present?
    super
  end

  def skippable?
    skip_call_to_action_text.present?
  end

  def journey
    task.section.journey
  end
end
