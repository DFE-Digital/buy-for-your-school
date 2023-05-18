module Support
  module TagBarHelper
    def tag_bar(tags, form_id, preposition:)
      render "support/helpers/tag_bar", tags:, form_id:, preposition:
    end
  end
end
