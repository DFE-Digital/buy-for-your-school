class Journey < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :sections, dependent: :destroy
  #has_many :visible_steps, -> { where(steps: {hidden: false}) }, class_name: "Step"
  belongs_to :user

  scope :visible_steps, -> {}

  validates :category, :liquid_template, presence: true

  def visible_steps
    steps = []
    sections.each do |section|
      section.tasks.each do |task|
        task.steps.each do |step|
          steps << step if step.hidden == false
        end
      end
    end
    steps
  end

  def all_steps_completed?
    visible_steps.any? && visible_steps.all? { |step| step.answer.present? }
  end

  def freshen!
    attributes = {}
    attributes[:last_worked_on] = Time.zone.now
    attributes[:started] = true unless started == true

    update(attributes)
  end
end
