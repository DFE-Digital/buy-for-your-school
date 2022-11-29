module FrameworkRequests
  class EnergyRequestAboutForm < BaseForm
    validates :energy_request_about, presence: true

    attr_writer :energy_request_about

    def energy_request_about
      @energy_request_about&.to_sym
    end

    def energy_request_about_options
      %i[energy_contract general_question something_else]
    end
  end
end
