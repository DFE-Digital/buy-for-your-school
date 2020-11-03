module ContentfulHelpers
  def stub_get_contentful_entry(
    entry_id: "1UjQurSOi5MWkcRuGxdXZS",
    fixture_filename: "radio-question-example.json"
  )
    raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/#{fixture_filename}")
    fake_contentful_question_response = JSON.parse(raw_response)

    contentful_client = instance_double(Contentful::Client)
    allow(Contentful::Client).to receive(:new)
      .with(space: anything, access_token: anything)
      .and_return(contentful_client)

    contentful_response = double(Contentful::Entry, id: entry_id)
    allow(contentful_client).to receive(:entry)
      .with(entry_id)
      .and_return(contentful_response)

    allow(contentful_response).to receive(:raw)
      .and_return(fake_contentful_question_response)
  end
end
