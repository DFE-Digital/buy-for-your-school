#
# Mock Contentful data loaded from JSON fixtures
#
module ContentfulHelpers
  # TODO: replace "contentful_fixture_filename"/"fixture_filename" with the more succinct "fixture" param
  #
  def stub_contentful_entry(
    entry_id: "radio-question",
    fixture_filename: "radio-question-example.json",
    client: stub_client
  )
    contentful_response = fake_contentful_step(contentful_fixture_filename: fixture_filename)

    allow(client).to receive(:by_id).with(entry_id).and_return(contentful_response)
  end

  def stub_multiple_contentful_categories(category_fixtures:)
    client = stub_client

    contentful_array = instance_double(Contentful::Array)
    contentful_categories = category_fixtures.map do |fixture|
      stub_contentful_category(fixture_filename: fixture, client: client)
    end

    iterator = allow(contentful_array).to receive(:each)
    contentful_categories.each { |category| iterator.and_yield(category) }

    allow(contentful_array).to receive(:none?).and_return(category_fixtures.empty?)
    allow(client).to receive(:by_type).with(:category).and_return(contentful_array)
  end

  def stub_contentful_category(
    fixture_filename:,
    stub_sections: true,
    stub_tasks: true,
    client: stub_client
  )
    category = fake_contentful_category(contentful_fixture_filename: fixture_filename)

    allow(client).to receive(:by_id).with(category.id).and_return(category)
    allow(client).to receive(:by_slug).with(:category, category.slug).and_return(category)

    if stub_sections
      sections = stub_contentful_sections(category: category, client: client)

      if stub_tasks
        stub_contentful_tasks(sections: sections, client: client)
      end
    end

    category
  end

  def stub_contentful_sections(category:, client: stub_client)
    fake_sections = category.sections.map do |section|
      fake_section =
        fake_contentful_section(
          contentful_fixture_filename: "sections/#{section.id}.json",
          client: client,
        )

      allow(client).to receive(:by_id).with(fake_section.id).and_return(fake_section)

      fake_section
    end

    allow(category).to receive(:sections).and_return(fake_sections)
    fake_sections
  end

  def stub_contentful_tasks(sections:, client: stub_client)
    sections.each do |section|
      fake_tasks = section.tasks.map do |task|
        fake_task = fake_contentful_task(contentful_fixture_filename: "tasks/#{task.id}.json")

        allow(client).to receive(:by_id).with(fake_task.id).and_return(fake_task)

        fake_task
      end
      allow(section).to receive(:tasks).and_return(fake_tasks)

      stub_contentful_steps(tasks: fake_tasks, client: client)
    end
  end

  def stub_contentful_steps(tasks:, client: stub_client)
    tasks.each do |task|
      fake_steps = task.steps.map do |step|
        fake_step = fake_contentful_step(contentful_fixture_filename: "steps/#{step.id}.json")

        allow(client).to receive(:by_id).with(fake_step.id).and_return(fake_step)

        fake_step
      end

      allow(task).to receive(:steps).and_return(fake_steps)
    end
  end

  # Mock our internal client interface
  #
  def stub_client
    client = instance_double(Content::Client)
    allow(Content::Client).to receive(:new).and_return(client)
    allow(client).to receive(:environment).and_return("contentful environment")
    allow(client).to receive(:space).and_return("contentful space")
    allow(client).to receive(:api_url).and_return("contentful api_url")
    client
  end

  def stub_contentful_client
    contentful_client = instance_double(Contentful::Client)
    allow(Contentful::Client).to receive(:new)
      .with(
        access_token: anything,
        api_url: anything,
        application_name: anything,
        application_version: anything,
        environment: anything,
        raise_errors: anything,
        space: anything,
      )
      .and_return(contentful_client)
    contentful_client
  end

  def fake_contentful_category(contentful_fixture_filename:)
    raw_response = File.read(Rails.root.join("spec/fixtures/contentful/001-categories/#{contentful_fixture_filename}"))
    hash_response = JSON.parse(raw_response)

    sections = hash_response.dig("fields", "sections").map do |section|
      double(id: section.dig("sys", "id"))
    end

    combined_specification_template = [
      hash_response.dig("fields", "specificationTemplate"),
      hash_response.dig("fields", "specificationTemplatePart2"),
    ].compact.join("\n")

    category_double = double(
      Contentful::Entry,
      id: hash_response.dig("sys", "id"),
      title: hash_response.dig("fields", "title"),
      description: hash_response.dig("fields", "description"),
      sections: sections,
      specification_template: hash_response.dig("fields", "specificationTemplate"),
      specification_template_part2: hash_response.dig("fields", "specificationTemplatePart2"),
      combined_specification_template: combined_specification_template,
      environment: double(id: "test"),
      slug: hash_response.dig("fields", "slug"),
    )

    allow(category_double).to receive(:combined_specification_template=)
      .with(combined_specification_template)

    category_double
  end

  def fake_contentful_section(contentful_fixture_filename:, client: stub_client)
    raw_response = File.read(Rails.root.join("spec/fixtures/contentful/002-#{contentful_fixture_filename}"))
    hash_response = JSON.parse(raw_response)

    tasks = hash_response.dig("fields", "tasks")

    section = double(
      Contentful::Entry,
      id: hash_response.dig("sys", "id"),
      title: hash_response.dig("fields", "title"),
      raw: hash_response,
      tasks: tasks.map { |task_hash| double(id: task_hash.dig("sys", "id")) },
    )

    fake_tasks = section.tasks.map do |task|
      fake_task = fake_contentful_task(contentful_fixture_filename: "tasks/#{task.id}.json")

      allow(client).to receive(:by_id).with(fake_task.id).and_return(fake_task)

      fake_task
    end
    allow(section).to receive(:tasks).and_return(fake_tasks)
    stub_contentful_steps(tasks: fake_tasks, client: client)
    section
  end

  def fake_contentful_task(contentful_fixture_filename:)
    raw_response = File.read(Rails.root.join("spec/fixtures/contentful/003-#{contentful_fixture_filename}"))
    hash_response = JSON.parse(raw_response)

    task = double(
      Contentful::Entry,
      id: hash_response.dig("sys", "id"),
      content_type: double(id: hash_response.dig("sys", "contentType", "sys", "id")),
      raw: hash_response,
      title: hash_response.dig("fields", "title"),
    )

    steps = hash_response.dig("fields", "steps").map { |step_hash| double(id: step_hash.dig("sys", "id")) }

    allow(task).to receive(:steps).and_return steps
    task
  end

  def fake_contentful_step(contentful_fixture_filename:)
    raw_response = File.read(Rails.root.join("spec/fixtures/contentful/004-#{contentful_fixture_filename}"))
    hash_response = JSON.parse(raw_response)

    fields = hash_response["fields"].dup.transform_keys!(&:underscore).symbolize_keys!

    double(
      Contentful::Entry,
      id: hash_response.dig("sys", "id"),
      revision: hash_response.dig("sys", "revision"),
      updated_at: Date.parse(hash_response.dig("sys", "updatedAt")),
      space: double(id: hash_response.dig("sys", "space", "sys", "id")),
      environment: double(id: hash_response.dig("sys", "environment", "sys", "id")),
      content_type: double(id: hash_response.dig("sys", "contentType", "sys", "id")),
      raw: hash_response,
      fields: fields,
      **fields,
    )
  end
end
