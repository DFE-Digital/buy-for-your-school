RSpec.describe "Search tasks" do
  before do
    Rake.application.rake_require("tasks/search")
    Rake::Task.define_task(:environment)
  end

  after do
    Rake::Task["search:index"].reenable
    Rake::Task["search:clear"].reenable
  end

  describe "search:index" do
    subject(:invoke_task) { Rake::Task["search:index"].invoke }

    let(:search_client) { instance_double(SearchClient, indices:) }
    let(:indices) { double("indices") }
    let(:category) { instance_double(FABS::Category, id: "category-id", title: "ICT", slug: "ict") }
    let(:solution_with_category) do
      instance_double(
        Solution,
        id: "solution-1",
        title: "Laptops",
        description: "Buying laptops",
        summary: "Laptop summary",
        slug: "laptops",
        provider_reference: "ABC-123",
        primary_category: category,
      )
    end
    let(:solution_without_category) do
      instance_double(
        Solution,
        id: "solution-2",
        title: "Printers",
        description: "Buying printers",
        summary: "Printer summary",
        slug: "printers",
        provider_reference: "DEF-456",
        primary_category: nil,
      )
    end
    let(:entries) { [solution_with_category, solution_without_category] }

    before do
      allow(SearchClient).to receive(:instance).and_return(search_client)
      allow(Solution).to receive(:all).and_return(entries)
      allow(indices).to receive(:exists?).with(index: "solution-data").and_return(false)
      allow(indices).to receive(:create)
      allow(search_client).to receive(:bulk)
    end

    it "creates the search index and indexes all solutions" do
      expect(indices).to receive(:create).with(
        index: "solution-data",
        body: {
          settings: { number_of_shards: 1, number_of_replicas: 0 },
          mappings: {
            properties: {
              id: { type: "keyword" },
              title: { type: "text", analyzer: "english" },
              description: { type: "text", analyzer: "english" },
              summary: { type: "text", analyzer: "english" },
              slug: { type: "keyword" },
              provider_reference: { type: "keyword" },
            },
          },
        },
      )
      expect(search_client).to receive(:bulk).with(
        body: [
          {
            index: {
              _index: "solution-data",
              _id: "solution-1",
              data: {
                id: "solution-1",
                title: "Laptops",
                description: "Buying laptops",
                summary: "Laptop summary",
                slug: "laptops",
                provider_reference: "ABC-123",
                primary_category: {
                  id: "category-id",
                  title: "ICT",
                  slug: "ict",
                },
              },
            },
          },
          {
            index: {
              _index: "solution-data",
              _id: "solution-2",
              data: {
                id: "solution-2",
                title: "Printers",
                description: "Buying printers",
                summary: "Printer summary",
                slug: "printers",
                provider_reference: "DEF-456",
                primary_category: nil,
              },
            },
          },
        ],
      )

      expect { invoke_task }
        .to output("Starting Contentful to search sync...\nSuccessfully indexed 2 entries into search index.\n")
        .to_stdout
    end

    context "when the search index already exists" do
      before do
        allow(indices).to receive(:exists?).with(index: "solution-data").and_return(true)
      end

      it "does not recreate the search index" do
        expect(indices).not_to receive(:create)

        invoke_task
      end
    end
  end

  describe "search:clear" do
    subject(:invoke_task) { Rake::Task["search:clear"].invoke }

    let(:search_client) { instance_double(SearchClient, indices:) }
    let(:indices) { double("indices") }

    before do
      allow(SearchClient).to receive(:instance).and_return(search_client)
    end

    context "when the search index exists" do
      before do
        allow(indices).to receive(:exists?).with(index: "solution-data").and_return(true)
        allow(search_client).to receive(:delete_by_query).and_return("deleted" => 64)
      end

      it "deletes all documents from the search index" do
        expect(search_client).to receive(:delete_by_query).with(
          index: "solution-data",
          body: {
            query: {
              match_all: {},
            },
          },
          refresh: true,
        )

        expect { invoke_task }
          .to output(
            "Clearing search index solution-data...\n" \
            "Deleted 64 documents from search index solution-data.\n",
          )
          .to_stdout
      end
    end

    context "when the search index does not exist" do
      before do
        allow(indices).to receive(:exists?).with(index: "solution-data").and_return(false)
      end

      it "does not attempt to delete documents" do
        expect(search_client).not_to receive(:delete_by_query)

        expect { invoke_task }
          .to output("Search index solution-data does not exist.\n")
          .to_stdout
      end
    end
  end
end
