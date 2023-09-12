class Frameworks::ActivityLoggableVersion < PaperTrail::Version
  include Presentable

  def item_association_at_version_or_current(association:, id:, version_at: created_at)
    current_version_of_association = item.class.reflections[association].klass.find_by(id:)
    current_version_of_association.try(:version_at, version_at).presence || current_version_of_association
  end
end
