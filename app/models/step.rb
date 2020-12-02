class Step < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :journey

  has_one :radio_answer
  has_one :short_text_answer
  has_one :long_text_answer

  def radio_options
    options.map { |option| OpenStruct.new(id: option.downcase, name: option.titleize) }
  end

  def answer
    @answer ||= radio_answer || short_text_answer || long_text_answer
  end
end
