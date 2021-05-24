class Journey < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :sections, dependent: :destroy
  has_many :tasks, through: :sections, class_name: "Task"
  has_many :steps, through: :tasks, class_name: "Step"
  belongs_to :user

  validates :category, :contentful_id, :liquid_template, presence: true

  def visible_steps
    steps.where(hidden: false)
  end

  def all_steps_completed?
    visible_steps.all? { |step| step.answer.present? }
  end

  def freshen!
    attributes = {}
    attributes[:last_worked_on] = Time.zone.now
    attributes[:started] = true unless started == true

    update(attributes)
  end
end
