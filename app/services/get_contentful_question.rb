class GetContentfulQuestion
  def call
    # TODO: Spec fixture only used for the first slice, needs a real API call
    JSON.parse(
      File.read("#{Rails.root}/spec/fixtures/contentful/radio-question-example.json")
    )
  end
end
