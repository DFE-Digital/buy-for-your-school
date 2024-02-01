class RequestForHelpCategory < ApplicationRecord
  belongs_to :parent, class_name: "RequestForHelpCategory", optional: true
  has_many :sub_categories, class_name: "RequestForHelpCategory", foreign_key: "parent_id"
  belongs_to :support_category, class_name: "Support::Category", optional: true

  default_scope { order(Arel.sql("CASE WHEN request_for_help_categories.title = 'Other' THEN 1 ELSE 0 END ASC, request_for_help_categories.title ASC")) }

  scope :top_level, -> { where(parent_id: nil) }
  scope :active, -> { where(archived: false) }

  enum :flow, { services: 0, goods: 1, energy: 2, not_fully_supported: 3 }, suffix: true

  def self.find_by_path(path)
    slugs = path.split("/")
    parent = nil

    slugs.each do |slug|
      category = RequestForHelpCategory.find_by(slug:, parent:)
      return nil unless category

      parent = category
    end

    parent
  end

  def ancestors
    return [] unless parent

    parent.ancestors + [parent]
  end

  def hierarchy
    return [self] unless parent

    parent.hierarchy + [self]
  end

  def is_descendant_of?(category) = ancestors.include? category

  def find_next_in_hierarchy_to(descendant)
    return unless descendant.is_descendant_of?(self)

    parent_hierarchy = hierarchy
    descendant_hierarchy = descendant.hierarchy

    descendant_hierarchy.each_with_index do |category, index|
      return category if index >= parent_hierarchy.length
    end
  end

  def root_parent
    return self if parent.nil?

    parent.root_parent
  end

  def ancestors_slug = ancestors.map(&:slug).join("/")

  def other? = slug == "other"

  def gas? = slug == "gas"

  def electricity? = slug == "electricity"

  def is_energy_or_services? = flow.in?(%w[energy services])
end
