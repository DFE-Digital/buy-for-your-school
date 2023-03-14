module Support
  class EditCaseAttachableForm
    include ActiveModel::Model
    attr_accessor :custom_name, :description, :update_action

    def self.from(attachable)
      new(custom_name: attachable.custom_name, description: attachable.description)
    end

    def update!
      update_action.call(custom_name:, description:)
    end
  end
end
