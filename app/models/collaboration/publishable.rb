module Collaboration::Publishable
  extend ActiveSupport::Concern

  included do
    has_paper_trail versions: { class_name: "Collaboration::Version" }, unless: ->(p) { p.draft? }

    has_many :drafts, class_name: name, foreign_key: :published_version_id
    belongs_to :live, class_name: name, foreign_key: :published_version_id, optional: true

    enum :state, { draft: 0, published: 1 }

    amoeba do
      exclude_association :drafts
      set state: :draft

      customize(->(published, draft) { draft.live = published })

      enable
    end
  end

  class_methods do
    def create_draft!(attributes = {})
      create!(**attributes, state: :draft)
    end
  end

  def create_draft!
    return if draft_version.present?

    amoeba_dup.save!
    amoeba_dup
  end

  def initial_publish?
    draft? && live_version.blank?
  end

  def live_version
    return self if published?

    live
  end

  def draft_version
    return self if draft?

    drafts.first if drafts.present?
  end

  def pending_changes?
    return true if initial_publish?

    proposed_changes.present?
  end

  def publish!
    return unless draft?

    transaction do
      if live_version.present?
        live_version.assign_attributes(attributes.except(*excluded_fields))
        live_version.save!
      else
        published!
      end

      self.class.reflect_on_all_associations(:has_many).each do |association|
        next if association.name.in? %i[drafts versions]

        send(association.name).each(&:publish!)
      end
      destroy! if draft?
    end
  end

  def proposed_changes
    return [] if live_version.blank?

    changes = []
    live_version.attributes.except(*excluded_fields).each do |attribute, value|
      next if value.blank?

      changes << OpenStruct.new(
        field: attribute,
        from: value,
        to: draft_version.send(attribute),
      )
    end
    changes
  end

  def presentable_attributes
    attrs = attributes.except(*excluded_fields).compact
    relevant_associations.each do |association|
      # attrs.merge(association.name, send(association.name).each(&:presentable_attributes))
      attrs[association.name.to_s] = send(association.name).map(&:presentable_attributes)
    end
    attrs
  end

private

  def excluded_fields
    %w[id state created_at updated_at versions].freeze + self.class.reflect_on_all_associations(:belongs_to).map(&:foreign_key)
  end

  def relevant_associations
    self.class.reflect_on_all_associations(:has_many).reject { |association| association.name.in? %i[drafts versions] }
  end
end
