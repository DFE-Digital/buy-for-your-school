class Step < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :journey

  has_one :radio_answer
  has_one :short_text_answer
  has_one :long_text_answer
  has_one :single_date_answer
  has_one :checkbox_answers

  scope :that_are_questions, -> { where(contentful_model: "question") }

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

  def options
    raw.dig("fields", "extendedOptions") || legacy_options(super)
  end

  def options_list
    options.map { |hash| hash["value"] }
  end

  # TODO: Remove this migration step when extendedOptions is ready to be solely
  # relied upon in all environments.
  # Convert the legacy 'options' field into the same structure as extendedOptions
  # so the view only needs to support one data structure:
  #
  # [{"value"=>"Foo"}, {"value"=>"Bar"}] rather than ["Foo", "Bar"]
  private def legacy_options(legacy_options)
    return nil if legacy_options.nil?
    legacy_options.inject([]) do |array, legacy_option|
      array << Hash["value" => legacy_option]
    end
  end
end
