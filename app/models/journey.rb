class Journey < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :steps

  validates :liquid_template, presence: true

  def all_tasks_completed?
    # return false if any step does not have an answer
    steps.each do |step|
      if !step.answer
        return false
      end
    end
    true
  end
end
