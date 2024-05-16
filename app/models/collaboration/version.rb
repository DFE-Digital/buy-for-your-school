module Collaboration
  class Version < PaperTrail::Version
    include ::Version::Presentable

    before_create do
      self.whodunnit = Current.actor
    end

    def field_changes
      object_changes.except("id", "created_at", "updated_at", "published_version_id", "drafts")
    end

    def item_association_at_version_or_current(association:, id:, version_at: created_at)
      current_version_of_association = item.class.reflections[association].klass.find_by(id:)
      current_version_of_association.try(:version_at, version_at).presence || current_version_of_association
    end

    # def changeset_full
    #   associations = item.class.reflect_on_all_associations(:has_many)
    #     .reject { |association| association.name.in?(%i[drafts versions]) || association.through_reflection.present? }
    #     .map { |association| [association.name, item.send(association.name).map { |a| a.paper_trail.version_at(created_at).version.changeset_full }] }
    #     .to_h
    #   changeset.merge(associations)
    # end
  end
end
