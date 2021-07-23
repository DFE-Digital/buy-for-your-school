#
# Mock Contentful data loaded from JSON fixtures
#
module ContentfulHelpers
  def stub_contentful_entry(
    entry_id: "radio-question",
    fixture_filename: "radio-question-example.json",
    contentful_connector: stub_contentful_connector
  )
    contentful_response = fake_contentful_step(contentful_fixture_filename: fixture_filename)

    allow(contentful_connector).to receive(:by_id).with(entry_id).and_return(contentful_response)
  end

  def stub_multiple_contentful_categories(category_fixtures:)
    contentful_connector = stub_contentful_connector

    contentful_array = instance_double(Contentful::Array)
    # TODO: work with multiple category fixtures
    contentful_category = stub_contentful_category(fixture_filename: category_fixtures.first, contentful_connector: contentful_connector)

    allow(contentful_array).to receive(:each).and_yield(contentful_category)
    allow(contentful_connector).to receive(:by_type).with("category").and_return(contentful_array)
  end

  def stub_contentful_category(
    fixture_filename:,
    stub_sections: true,
    stub_tasks: true,
    contentful_connector: stub_contentful_connector
  )
    category = fake_contentful_category(contentful_fixture_filename: fixture_filename)

    allow(contentful_connector).to receive(:by_id).with(category.id).and_return(category)

    if stub_sections
      sections = stub_contentful_sections(category: category, contentful_connector: contentful_connector)

      if stub_tasks
        stub_contentful_tasks(sections: sections, contentful_connector: contentful_connector)
      end
    end

    category
  end

  def stub_contentful_sections(category:, contentful_connector: stub_contentful_connector)
    fake_sections = category.sections.map do |section|
      fake_section =
        fake_contentful_section(
          contentful_fixture_filename: "sections/#{section.id}.json",
          contentful_connector: contentful_connector,
        )

      allow(contentful_connector).to receive(:by_id).with(fake_section.id).and_return(fake_section)

      fake_section
    end

    allow(category).to receive(:sections).and_return(fake_sections)
    fake_sections
  end

  def stub_contentful_tasks(sections:, contentful_connector: stub_contentful_connector)
    sections.each do |section|
      fake_tasks = section.tasks.map do |task|
        fake_task = fake_contentful_task(contentful_fixture_filename: "tasks/#{task.id}.json")

        allow(contentful_connector).to receive(:by_id).with(fake_task.id).and_return(fake_task)

        fake_task
      end
      allow(section).to receive(:tasks).and_return(fake_tasks)

      stub_contentful_steps(tasks: fake_tasks, contentful_connector: contentful_connector)
    end
  end

  def stub_contentful_steps(tasks:, contentful_connector: stub_contentful_connector)
    tasks.each do |task|
      fake_steps = task.steps.map do |step|
        fake_step = fake_contentful_step(contentful_fixture_filename: "steps/#{step.id}.json")

        allow(contentful_connector).to receive(:by_id).with(fake_step.id).and_return(fake_step)

        fake_step
      end

      allow(task).to receive(:steps).and_return(fake_steps)
    end
  end

  def stub_contentful_connector
    contentful_connector = instance_double(ContentfulConnector)
    allow(ContentfulConnector).to receive(:new).and_return(contentful_connector)
    contentful_connector
  end

  def stub_contentful_client
    contentful_client = instance_double(Contentful::Client)
    allow(Contentful::Client).to receive(:new)
      .with(api_url: anything, space: anything, environment: anything, access_token: anything)
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
    )

    allow(category_double).to receive(:combined_specification_template=)
      .with(combined_specification_template)

    category_double
  end

  def fake_contentful_section(contentful_fixture_filename:, contentful_connector: stub_contentful_connector)
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

      allow(contentful_connector).to receive(:by_id).with(fake_task.id).and_return(fake_task)

      fake_task
    end
    allow(section).to receive(:tasks).and_return(fake_tasks)
    stub_contentful_steps(tasks: fake_tasks, contentful_connector: contentful_connector)
    section
  end

  def fake_contentful_task(contentful_fixture_filename:)
    raw_response = File.read(Rails.root.join("spec/fixtures/contentful/003-#{contentful_fixture_filename}"))
    hash_response = JSON.parse(raw_response)

    task = double(
      Contentful::Entry,
      id: hash_response.dig("sys", "id"),
      title: hash_response.dig("fields", "title"),
      raw: hash_response,
      content_type: double(id: hash_response.dig("sys", "contentType", "sys", "id")),
    )

    steps = hash_response.dig("fields", "steps").map { |step_hash| double(id: step_hash.dig("sys", "id")) }

    allow(task).to receive(:steps).and_return steps
    task
  end

  def fake_contentful_step(contentful_fixture_filename:)
    raw_response = File.read(Rails.root.join("spec/fixtures/contentful/004-#{contentful_fixture_filename}"))
    hash_response = JSON.parse(raw_response)

    double(
      Contentful::Entry,
      id: hash_response.dig("sys", "id"),
      title: hash_response.dig("fields", "title"),
      type: hash_response.dig("fields", "type"),
      content_type: double(id: hash_response.dig("sys", "contentType", "sys", "id")),
      raw: hash_response,
      fields: hash_response["fields"].dup.transform_keys!(&:underscore).symbolize_keys!,
    )
  end
end
