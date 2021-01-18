module ContentfulHelpers
  def stub_get_contentful_entry(
    entry_id: "1UjQurSOi5MWkcRuGxdXZS",
    fixture_filename: "radio-question-example.json"
  )
    contentful_connector = stub_contentful_connector
    contentful_response = fake_contentful_entry(contentful_fixture_filename: fixture_filename)
    allow(contentful_connector).to receive(:get_entry_by_id)
      .with(entry_id)
      .and_return(contentful_response)
  end

  def stub_get_contentful_entries(
    entry_id: "5kZ9hIFDvNCEhjWs72SFwj",
    fixture_filename: "multiple-entries-example.json"
  )
    raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/#{fixture_filename}")

    contentful_connector = stub_contentful_connector
    contentful_response = fake_contentful_entry_array(contentful_fixture_filename: fixture_filename)
    allow(contentful_connector).to receive(:get_all_entries)
      .and_return(contentful_response)

    allow(contentful_response).to receive(:raw)
      .and_return(raw_response)
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

  def fake_contentful_entry_array(contentful_fixture_filename:)
    raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/#{contentful_fixture_filename}")
    response_hash = JSON.parse(raw_response)

    Contentful::ResourceBuilder.new(response_hash).run
  end
end
