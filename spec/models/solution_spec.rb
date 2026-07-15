require "rails_helper"

RSpec.describe Solution, type: :model do
  describe "#initialize" do
    subject(:solution) { described_class.new(entry) }

    let(:entry) do
      contentful_entry(
        id: "solution-id",
        title: "Technology products and associated services",
        description: "Buy technology products and associated services",
        summary: "Summary",
        slug: "technology-products-and-associated-services",
        provider_name: "Provider",
        provider_initials: "PR",
        suffix: "Suffix",
        primary_category: instance_double(FABS::Category),
      )
    end

    it "sets the attributes" do
      expect(solution).to have_attributes(
        id: be_present,
        title: be_present,
        summary: be_present,
        description: be_present,
        slug: be_present,
        suffix: be_present,
        provider_name: be_present,
      )
    end
  end

  describe ".all" do
    subject(:solutions) { described_class.all }

    let(:category_id) { "category-id" }
    let(:category) { instance_double(FABS::Category, id: category_id) }
    let(:other_category) { instance_double(FABS::Category, id: "other-category-id") }
    let(:entry_a) do
      contentful_entry(
        id: "solution-a",
        title: "Alpha solution",
        slug: "alpha-solution",
        primary_category: category,
        categories: [category],
      )
    end
    let(:entry_b) do
      contentful_entry(
        id: "solution-b",
        title: "beta solution",
        slug: "beta-solution",
        primary_category: category,
        categories: [category, other_category],
      )
    end

    before do
      allow(ContentfulClient).to receive(:entries).and_return([entry_a, entry_b])
    end

    it "fetches solutions from Contentful" do
      expect(solutions).to be_present
      expect(solutions).to be_a(Array)
      expect(solutions).to all(be_a(described_class))
    end

    it "fetches solutions in alphabetical order" do
      expect(solutions.map(&:title)).to eq(solutions.map(&:title).sort_by(&:downcase))
    end

    context "when filtering by category_id" do
      let(:solutions) do
        described_class.all(category_id:)
      end

      before do
        allow(ContentfulClient).to receive(:entries).with(
          hash_including(
            content_type: "solution",
            "fields.categories.sys.id[in]": category_id,
          ),
        ).and_return([entry_a])
      end

      it "returns only solutions from the specified category" do
        solutions.each do |solution|
          solution_category_ids = solution.categories.map(&:id)
          expect(solution_category_ids).to include(category_id)
        end
      end
    end
  end

  describe ".search" do
    subject(:search) { described_class.search(query:) }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("USE_OPENSEARCH", "false").and_return("false")
      allow(ContentfulClient).to receive(:entries).and_return([entry])
    end

    let(:query) { "technology" }
    let(:entry) do
      contentful_entry(
        id: "solution-search",
        title: "Technology solution",
        description: "Buy technology",
        summary: "Summary",
        slug: "technology-solution",
        primary_category: instance_double(FABS::Category),
      )
    end

    it "returns solutions matching the query" do
      expect(search).to all(be_a(described_class))
      expect(search.first).to have_attributes(
        id: be_present,
        title: be_present,
        summary: be_present,
        description: be_present,
        slug: be_present,
      )
    end
  end

  describe ".find_by_slug!" do
    subject(:solution) { described_class.find_by_slug!(slug) }

    context "when solution exists" do
      let(:slug) { "it-hardware" }
      let(:entry) do
        contentful_entry(
          id: "solution-slug",
          title: "IT hardware",
          description: "Buy IT hardware",
          summary: "Summary",
          slug:,
          primary_category: instance_double(FABS::Category),
        )
      end

      before do
        allow(ContentfulClient).to receive(:entries).and_return([entry])
      end

      it "returns the solution" do
        expect(solution).to be_a(described_class)
        expect(solution.slug).to eq(slug)
      end
    end

    context "when solution does not exist" do
      let(:slug) { "non-existent" }

      before do
        allow(ContentfulClient).to receive(:entries).and_return([])
      end

      it "raises ContentfulRecordNotFoundError" do
        expect { solution }.to raise_error(ContentfulRecordNotFoundError, "Solution not found")
      end
    end
  end

  describe ".find_by_id!" do
    subject(:solution) { described_class.find_by_id!(id) }

    context "when solution exists" do
      let(:id) { "1cFyWcuXyiTWce11GytE0C" }
      let(:entry) do
        contentful_entry(
          id:,
          title: "ID solution",
          description: "Buy by id",
          summary: "Summary",
          slug: "id-solution",
          primary_category: instance_double(FABS::Category),
        )
      end

      before do
        allow(ContentfulClient).to receive(:entries).and_return([entry])
      end

      it "returns the solution" do
        expect(solution).to be_a(described_class)
        expect(solution.id).to eq(id)
      end
    end

    context "when solution does not exist" do
      let(:id) { "non-existent" }

      before do
        allow(ContentfulClient).to receive(:entries).and_return([])
      end

      it "raises ContentfulRecordNotFoundError" do
        expect { solution }.to raise_error(ContentfulRecordNotFoundError, "Solution not found")
      end
    end
  end

  describe ".presentable?" do
    let(:minimal_attrs) do
      {
        title: "lord",
        slug: "banana",
        primary_category: instance_double(Category),
      }
    end

    it "is true if it has all required attributes" do
      params =
        OpenStruct.new(
          id: "ID",
          fields: minimal_attrs,
        )
      expect(described_class.new(params)).to be_presentable
    end

    it "requires a title" do
      params =
        OpenStruct.new(
          id: "ID",
          fields: minimal_attrs.merge(title: ""),
        )
      expect(described_class.new(params)).not_to be_presentable
    end

    it "requires a slug" do
      params =
        OpenStruct.new(
          id: "ID",
          fields: minimal_attrs.merge(slug: ""),
        )
      expect(described_class.new(params)).not_to be_presentable
    end

    it "requires a primary category" do
      params =
        OpenStruct.new(
          id: "ID",
          fields: minimal_attrs.merge(primary_category: nil),
        )
      expect(described_class.new(params)).not_to be_presentable
    end
  end

  def contentful_entry(id:, title:, slug:, primary_category:, description: "Description", summary: "Summary", provider_name: "Provider", provider_initials: "PI", url: "https://example.com", expiry: nil, suffix: nil, call_to_action: nil, categories: [], subcategories: [], buying_option_type: nil, provider_reference: nil)
    OpenStruct.new(
      id:,
      sys: { id: },
      fields: {
        title:,
        description:,
        summary:,
        slug:,
        provider_name:,
        provider_initials:,
        url:,
        expiry:,
        suffix:,
        call_to_action:,
        categories:,
        subcategories:,
        primary_category:,
        buying_option_type:,
        provider_reference:,
      },
    )
  end
end
