module Support
  class CaseSavingsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :savings_status, optional: true
    option :savings_estimate_method, optional: true
    option :savings_actual_method, optional: true
    option :savings_estimate, optional: true
    option :savings_actual, optional: true
  end
end