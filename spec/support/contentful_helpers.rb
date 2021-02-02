module ContentfulHelpers
  def stub_contentful_entry(
    entry_id: "radio-question",
    fixture_filename: "radio-question-example.json"
  )
    contentful_connector = stub_contentful_connector
    contentful_response = fake_contentful_entry(contentful_fixture_filename: fixture_filename)
    allow(contentful_connector).to receive(:get_entry_by_id)
      .with(entry_id)
      .and_return(contentful_response)
  end

  def stub_contentful_category(
    fixture_filename:,
    stub_steps: true,
    contentful_connector: instance_double(ContentfulConnector)
  )
    category = fake_contentful_category(contentful_fixture_filename: fixture_filename)

    allow(ContentfulConnector).to receive(:new)
      .and_return(contentful_connector)

    allow(contentful_connector).to receive(:get_entry_by_id)
      .with(category.id)
      .and_return(category)

    if stub_steps
      stub_contentful_category_steps(category: category, contentful_connector: contentful_connector)
    end

    category
  end

  def stub_contentful_category_steps(
    category:,
    contentful_connector: instance_double(ContentfulConnector)
  )
    return if category.steps.count.zero?

    allow(ContentfulConnector).to receive(:new)
      .and_return(contentful_connector)

    category.steps.each do |step|
      step = fake_contentful_entry(contentful_fixture_filename: "steps/#{step.id}.json")
      allow(contentful_connector).to receive(:get_entry_by_id)
        .with(step.id)
        .and_return(step)
    end
  end

  def stub_contentful_connector
    contentful_connector = instance_double(ContentfulConnector)
    expect(ContentfulConnector).to receive(:new)
      .and_return(contentful_connector)
    contentful_connector
  end

  def stub_contentful_client
    contentful_client = instance_double(Contentful::Client)
    expect(Contentful::Client).to receive(:new)
      .with(api_url: anything, space: anything, environment: anything, access_token: anything)
      .and_return(contentful_client)
    contentful_client
  end

  def fake_contentful_category(contentful_fixture_filename:)
    raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/categories/#{contentful_fixture_filename}")
    hash_response = JSON.parse(raw_response)

    steps = hash_response.dig("fields", "steps").map { |step| double(id: step.dig("sys", "id")) }

    double(
      Contentful::Entry,
      id: hash_response.dig("sys", "id"),
      steps: steps,
      specification_template: hash_response.dig("fields", "specification_template")
    )
  end

  def fake_contentful_entry(contentful_fixture_filename:)
    raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/#{contentful_fixture_filename}")
    hash_response = JSON.parse(raw_response)

    double(
      Contentful::Entry,
      id: hash_response.dig("sys", "id"),
      title: hash_response.dig("fields", "title"),
      help_text: hash_response.dig("fields", "helpText"),
      body: hash_response.dig("fields", "body"),
      extended_options: hash_response.dig("fields", "extendedOptions"),
      type: hash_response.dig("fields", "type"),
      next: double(id: hash_response.dig("fields", "next", "sys", "id")),
      primary_call_to_action: hash_response.dig("fields", "primaryCallToAction"),
      raw: hash_response,
      content_type: double(id: hash_response.dig("sys", "contentType", "sys", "id"))
    )
  end
end
