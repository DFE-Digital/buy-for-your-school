require "types"
require "dry-initializer"

# @abstract Form Object for multi-step questionnaires
#
# @author Peter Hamilton
#
class SupportForm
  extend Dry::Initializer
  include NavigatableForm

  # @see https://design-system.service.gov.uk/components/error-summary/
  #
  class ErrorSummary
    extend Dry::Initializer

    # @example
    #
    #   { phone_number: ["size cannot be less than 10"] }
    #
    param :messages, Types::Hash, default: proc { {} }

    delegate :any?, to: :messages
  end

  # field validation error messages
  option :messages, Types::Hash, default: proc { {} }

  # @see [SupportRequest] attributes
  option :phone_number, optional: true # 1
  option :journey_id, optional: true   # 2 (option for 'none')
  option :category_id, optional: true  # 3 (skipped if 2)
  option :message_body, optional: true # 4 (last)

  # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
  #
  # @return [ErrorSummary]
  def errors
    ErrorSummary.new(messages)
  end

  # @see SupportRequestsController#create
  #
  # @return [Boolean] journey UUID is present
  def has_journey?
    journey_id.present? && journey_id != "none"
  end

  # @see SupportRequestsController#update
  #
  # @return [Boolean] category UUID is present
  def has_category?
    !category_id.nil?
  end

  # @return [nil]
  def forget_category!
    instance_variable_set :@category_id, nil
  end

  # @return [nil]
  def forget_journey!
    instance_variable_set :@journey_id, nil
  end

  # @see SupportRequestsController#update
  #
  # @return [Hash] form parms as support request attributes
  def to_h
    self.class.dry_initializer.attributes(self).except(
      :messages,
      :direction,
      :step,
      :navigator,
    )
  end
end
