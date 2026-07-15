require "rails_helper"

RSpec.describe FABS::Category, type: :model do
  describe "#initialize" do
    subject(:category) { described_class.new(entry) }

    let(:entry) { category_entry }

    it "sets the attributes" do
      expect(category).to have_attributes(
        id: be_present,
        title: be_present,
        description: be_present,
        slug: be_present,
        subcategories: be_an(Array),
        related_content: be_an(Array),
      )
    end
  end

  describe "#to_param" do
    subject(:category) { described_class.new(entry) }

    let(:entry) { category_entry }

    it "returns the slug" do
      expect(category.to_param).to eq entry.fields[:slug]
    end
  end

  describe ".all" do
    let(:category_ids) { %w[category-1 category-2] }
    let(:category_entry_a) do
      category_entry(id: "category-1", title: "Alpha category", slug: "alpha-category")
    end
    let(:category_entry_b) do
      category_entry(id: "category-2", title: "beta category", slug: "beta-category")
    end

    before do
      allow(Solution).to receive(:unique_category_ids).and_return(category_ids)
      allow(ContentfulClient).to receive(:entries).and_return([category_entry_a, category_entry_b])
    end

    it "fetches categories from Contentful" do
      categories = described_class.all
      expect(categories).to be_present
      expect(categories).to be_a(Array)
      expect(categories).to all(be_a(described_class))
    end

    it "fetches categories in alphabetical order" do
      categories = described_class.all
      expect(categories.map(&:title)).to eq(categories.map(&:title).sort_by(&:downcase))
    end

    it "does not include categories without solutions" do
      categories = described_class.all
      category_slugs = categories.map(&:slug)
      expect(category_slugs).not_to include("category-without-any-solution")
    end
  end

  describe "solutions ordering" do
    subject(:category) { described_class.new(entry) }

    let(:entry) { category_entry(subcategories: default_subcategories) }

    it "orders solutions alphabetically by title" do
      solution_titles = category.solutions.map(&:title)
      expect(solution_titles).to eq(solution_titles.sort_by(&:downcase))
    end
  end

  describe "#filtered_solutions" do
    subject(:category) { described_class.new(entry) }

    let(:entry) { category_entry(subcategories: default_subcategories) }
    let(:hardware_subcategory) { subcategory_entry(id: "subcat-hardware", title: "Hardware", slug: "hardware") }
    let(:software_subcategory) { subcategory_entry(id: "subcat-software", title: "Software", slug: "software") }
    let(:all_solutions) do
      [
        solution_model(slug: "audio-visual-solutions", title: "Audio visual solutions", subcategories: [hardware_subcategory]),
        solution_model(slug: "corporate-software", title: "Corporate software", subcategories: [software_subcategory]),
        solution_model(slug: "electronic-catering-management-and-payment-solutions", title: "Electronic catering management and payment solutions", subcategories: [hardware_subcategory]),
        solution_model(slug: "ict-procurement", title: "ICT procurement", subcategories: [hardware_subcategory]),
        solution_model(slug: "g-cloud", title: "G-Cloud", subcategories: [software_subcategory]),
        solution_model(slug: "it-hardware", title: "IT hardware", subcategories: [hardware_subcategory]),
        solution_model(slug: "microsoft-shape-the-future", title: "Microsoft shape the future", subcategories: [hardware_subcategory]),
        solution_model(slug: "outsourced-ict", title: "Outsourced ICT", subcategories: [software_subcategory]),
        solution_model(slug: "software-application-solutions", title: "Software application solutions", subcategories: [software_subcategory]),
        solution_model(slug: "software-licenses", title: "Software licenses", subcategories: [software_subcategory]),
        solution_model(slug: "sustainable-hardware-asset-recycling-and-data-destruction", title: "Sustainable hardware asset recycling and data destruction", subcategories: [hardware_subcategory]),
        solution_model(slug: "technology-products-and-associated-services-2", title: "Technology products and associated services 2", subcategories: [hardware_subcategory, software_subcategory]),
      ]
    end

    before do
      allow(category).to receive(:solutions).and_return(all_solutions)
    end

    it "filters solutions by subcategory slugs" do
      subcategory_slugs = %w[hardware software]
      filtered = category.filtered_solutions(subcategory_slugs:)
      expected_solution_slugs = %w[audio-visual-solutions corporate-software electronic-catering-management-and-payment-solutions ict-procurement g-cloud it-hardware microsoft-shape-the-future outsourced-ict software-application-solutions software-licenses sustainable-hardware-asset-recycling-and-data-destruction technology-products-and-associated-services-2]

      expect(filtered).to be_an(Array)
      expect(filtered).to all(be_a(Solution))
      expect(filtered.map(&:slug)).to match_array(expected_solution_slugs)
    end

    it "returns all solutions when subcategory_slugs is nil" do
      filtered_solutions = category.filtered_solutions(subcategory_slugs: nil)
      all_solutions = category.solutions
      expect(filtered_solutions).to eq(all_solutions)
    end

    it "returns all solutions when subcategory_slugs is empty" do
      filtered_solutions = category.filtered_solutions(subcategory_slugs: [])
      all_solutions = category.solutions
      expect(filtered_solutions).to eq(all_solutions)
    end

    it "excludes solutions that don't match any of the specified subcategory slugs" do
      subcategory_slugs = %w[hardware]
      filtered = category.filtered_solutions(subcategory_slugs:)
      expect(filtered.map(&:slug)).not_to include("software-licenses")
    end
  end

  describe ".find_by_slug!" do
    it "fetches a category by its slug from Contentful" do
      allow(ContentfulClient).to receive(:entries).and_return([category_entry])

      category = described_class.find_by_slug!("it")
      expect(category).to be_present
      expect(category).to be_a(described_class)
      expect(category.slug).to eq("it")
    end

    it "raises ContentfulRecordNotFoundError if no category is found by the given slug" do
      allow(ContentfulClient).to receive(:entries).and_return([])

      expect { described_class.find_by_slug!("non-existent-slug") }.to raise_error(ContentfulRecordNotFoundError, "Category not found")
    end
  end

  describe "#subcategories" do
    subject(:category) { described_class.new(entry) }

    let(:entry) do
      category_entry(
        subcategories: [
          subcategory_entry(id: "subcat-1", title: "Broadband and wifi", slug: "broadband-and-wifi"),
          subcategory_entry(id: "subcat-2", title: "Cloud-based solutions", slug: "cloud-based-solutions"),
          subcategory_entry(id: "subcat-3", title: "Cyber security", slug: "cyber-security"),
          subcategory_entry(id: "subcat-4", title: "Hardware", slug: "hardware"),
          subcategory_entry(id: "subcat-5", title: "IT consultancy", slug: "it-consultancy"),
          subcategory_entry(id: "subcat-6", title: "Management information systems", slug: "management-information-systems"),
          subcategory_entry(id: "subcat-7", title: "Networking and end-to-end services", slug: "networking-and-end-to-end-services"),
          subcategory_entry(id: "subcat-8", title: "Print, copy, and scan", slug: "print-copy-and-scan"),
          subcategory_entry(id: "subcat-9", title: "Software", slug: "software"),
        ],
      )
    end

    it "returns an array of Subcategory objects with titles in alphabetical order" do
      expected_titles = [
        "Broadband and wifi",
        "Cloud-based solutions",
        "Cyber security",
        "Hardware",
        "IT consultancy",
        "Management information systems",
        "Networking and end-to-end services",
        "Print, copy, and scan",
        "Software",
      ]

      expect(category.subcategories).to all(be_a(Subcategory))
      expect(category.subcategories.map(&:title)).to eq(expected_titles)
    end
  end

  describe ".search" do
    subject(:search) { described_class.search(query:) }

    let(:query) { "catering" }

    before do
      allow(ContentfulClient).to receive(:entries).and_return([category_entry])
    end

    it "returns categories matching the query" do
      expect(search).to all(be_a(described_class))
      expect(search.first).to have_attributes(
        id: be_present,
        title: be_present,
        description: be_present,
        slug: be_present,
      )
    end
  end

  describe "#related_content" do
    subject(:category) { described_class.new(entry) }

    let(:entry) { category_entry(related_content: [related_content_entry]) }

    it "returns an array of RelatedContent objects" do
      expect(category.related_content).to all(be_a(RelatedContent))
    end
  end

  def category_entry(id: "category-id", title: "IT", description: "Category description", slug: "it", subcategories: [], banner: nil, related_content: [])
    OpenStruct.new(
      id:,
      sys: { id: },
      fields: {
        title:,
        description:,
        slug:,
        subcategories: subcategories,
        banner:,
        related_content:,
      },
    )
  end

  def subcategory_entry(id:, title:, slug:)
    OpenStruct.new(id:, fields: { title:, slug: })
  end

  def solution_model(slug:, title:, subcategories: [])
    Solution.new(
      OpenStruct.new(
        id: slug,
        fields: {
          title:,
          description: "Description",
          summary: "Summary",
          slug:,
          primary_category: instance_double(FABS::Category),
          subcategories:,
        },
      ),
    )
  end

  def default_subcategories
    [
      subcategory_entry(id: "subcat-2", title: "Software", slug: "software"),
      subcategory_entry(id: "subcat-1", title: "Hardware", slug: "hardware"),
    ]
  end

  def related_content_entry(id: "related-content-id", link_text: "Related content", url: "https://example.com/related")
    OpenStruct.new(
      id:,
      fields: {
        link_text:,
        url:,
      },
    )
  end
end
