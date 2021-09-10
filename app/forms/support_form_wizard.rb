class SupportFormWizard
  include ActiveModel::Model

  STEPS = [1, 2, 3, 4].freeze

  attr_accessor :step

  def initialize(attrs = {})
    attr_accessors
    super(attrs)
  end

  def save
    return false unless valid?

    next_step
  end

  def next_step
    @step = @step.to_i + 1
  end

  def support_request
    @support_request ||= SupportRequest.new(params_cleaned_up)
  end

  class Step1 < SupportFormWizard
    validates :phone_number, presence: true
  end

  class Step2 < Step1
    validates :journey_id, presence: true
  end

  class Step3 < Step2
    validates :category_id, presence: true
  end

  class Step4 < Step3
    validates :message, presence: true
    validates :user, presence: true

    def save
      return false unless valid?

      support_request.save!
    end

    def last_step?
      true
    end
  end

  def last_step?
    false
  end

private

  def permitted_attributes
    %i[phone_number journey_id category_id message step user]
  end

  def attributes_hash
    {}.tap { |hash| permitted_attributes.each { |attr| hash[attr] = send(attr) } }
  end

  def attr_accessors
    permitted_attributes.each { |attr| class_eval { attr_accessor attr } }
  end

  def params_cleaned_up
    params = attributes_hash.reject { |_, v| v.blank? }
    params.delete(:step)
    params
  end
end
