FactoryBot.define do
  factory :page do
    title { Faker::Name.name }
    body { Faker::Markdown.sandwich }
    slug { Faker::Internet.slug }
    sidebar { Faker::Markdown.sandwich }
    contentful_id { Faker::Alphanumeric.alphanumeric }
    breadcrumbs { Array.new(5).map { Faker::Internet.domain_name } }
  end
end
