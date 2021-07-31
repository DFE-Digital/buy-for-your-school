# frozen_string_literal: true

# A Section belongs to a {Journey} and has many {Task}s and {Step}s
class Section < ApplicationRecord
  self.implicit_order_column = "order"

  default_scope { order(:order) }

  belongs_to :journey
  has_many :tasks, dependent: :destroy
  has_many :steps, through: :tasks, class_name: "Step"

  validates :title, :contentful_id, presence: true

  # @return [Boolean]
  #
  def incomplete?
    tasks.any?(&:incomplete?)
  end

  # Next incomplete task in order, or first from beginning
  #
  # @param current_task [Task]
  #
  # @return [Task, Nil]
  def next_incomplete_task(current_task = nil)
    return tasks.detect(&:incomplete?) unless current_task

    tasks.detect do |task|
      task.incomplete? && (task.order > current_task.order)
    end
  end
end
