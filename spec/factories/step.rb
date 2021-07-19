FactoryBot.define do
  factory :step do
    title { "What is your favourite colour?" }
    help_text { "Choose the primary colour closest to your choice" }
    contentful_id { SecureRandom.hex }
    raw { |attrs| { sys: { "id" => attrs["contentful_id"] } } }
    hidden { false }
    additional_step_rules { nil }
    primary_call_to_action_text { nil }
    skip_call_to_action_text { nil }

    association :task, factory: :task

    # @see specs/feature/additional_steps_spec
    trait :additional_steps do
      title { "has additional steps" }
      help_text { "answer yes for more steps" }
      order { 0 }
      contentful_model { "question" }
      contentful_type { "radios" }
      options { [{ "value" => "yes" }, { "value" => "no" }] }
      additional_step_rules do
        [{ "required_answer" => "yes", "question_identifiers" => %w[123 456] }]
      end
    end

    #
    # Statements
    #

    trait :statement do
      options { nil }
      contentful_model { "statement" }
      contentful_type { "markdown" }
      body { "## Heading 2" }
    end

    #
    # Questions
    #

    trait :radio do
      options { [{ "value" => "Red" }, { "value" => "Green" }, { "value" => "Blue" }] }
      contentful_model { "question" }
      contentful_type { "radios" }
    end

    trait :short_text do
      options { nil }
      contentful_model { "question" }
      contentful_type { "short_text" }
    end

    trait :long_text do
      options { nil }
      contentful_model { "question" }
      contentful_type { "long_text" }
    end

    trait :single_date do
      options { nil }
      contentful_model { "question" }
      contentful_type { "single_date" }
    end

    trait :checkbox_answers do
      options { [{ "value" => "Brown" }, { "value" => "Gold" }] }
      contentful_model { "question" }
      contentful_type { "checkboxes" }
    end

    trait :number do
      options { nil }
      contentful_model { "question" }
      contentful_type { "number" }
    end

    trait :currency do
      options { nil }
      contentful_model { "question" }
      contentful_type { "currency" }
    end
  end
end
