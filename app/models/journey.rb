# frozen_string_literal: true

# A Journey belongs to a {User} and consists of {Section}s.
class Journey < ApplicationRecord
  self.implicit_order_column = "created_at"

  has_many :sections, dependent: :destroy
  has_many :tasks, through: :sections, class_name: "Task"
  has_many :steps, through: :tasks, class_name: "Step"
  belongs_to :user

  validates :category, :contentful_id, :liquid_template, presence: true

  # @return [Step::ActiveRecord_AssociationRelation]
  def visible_steps
    steps.where(hidden: false)
  end

  def all_steps_completed?
    visible_steps.all? { |step| step.answer.present? }
  end

  # Updates the `last_worked_on` and `started` attributes to indicate that a journey has been started.
  #
  # This ensures started journeys are not removed during automated clean up.
  #
  # @return [Boolean]
  def freshen!
    attributes = {}
    attributes[:last_worked_on] = Time.zone.now
    attributes[:started] = true unless started == true

    update!(attributes)
  end
end
