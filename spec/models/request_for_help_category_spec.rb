require "rails_helper"

describe RequestForHelpCategory, type: :model do
  it { is_expected.to belong_to(:parent).class_name("RequestForHelpCategory").optional }
  it { is_expected.to have_many(:sub_categories).class_name("RequestForHelpCategory").with_foreign_key("parent_id") }
  it { is_expected.to belong_to(:support_category).class_name("Support::Category").optional }

  describe "default ordering" do
    before do
      create(:request_for_help_category, title: "D category")
      create(:request_for_help_category, title: "C category")
      create(:request_for_help_category, title: "A category")
      create(:request_for_help_category, title: "B category")
    end

    it "orders in ascending alphabetical order" do
      expect(described_class.all.pluck(:title)).to eq ["A category", "B category", "C category", "D category"]
    end
  end

  describe ".top_level" do
    before do
      cat_1 = create(:request_for_help_category, title: "Parent Category 1")
      cat_2 = create(:request_for_help_category, title: "Parent Category 2")
      create(:request_for_help_category, title: "Sub-Category 1", parent: cat_1)
      create(:request_for_help_category, title: "Sub-Category 2", parent: cat_2)
    end

    it "returns all categories without a parent" do
      top_level_categories = described_class.top_level
      expect(top_level_categories.size).to eq(2)
      expect(top_level_categories.pluck(:title)).to eq(["Parent Category 1", "Parent Category 2"])
    end
  end

  describe ".active" do
    before do
      create(:request_for_help_category, title: "D category")
      create(:request_for_help_category, title: "C category", archived: true)
      create(:request_for_help_category, title: "A category")
      create(:request_for_help_category, title: "B category")
    end

    it "returns active categories in ascending alphabetical order" do
      expect(described_class.active.pluck(:title)).to eq ["A category", "B category", "D category"]
    end
  end

  describe ".find_by_path" do
    context "when given path exists" do
      before do
        a = create(:request_for_help_category, slug: "a")
        b = create(:request_for_help_category, slug: "b", parent: a)
        create(:request_for_help_category, slug: "c", parent: b)
      end

      it "returns the category" do
        expect(described_class.find_by_path("a/b/c").slug).to eq("c")
      end
    end

    context "when given path does not exist" do
      it "returns nil" do
        expect(described_class.find_by_path("a/b/c")).to be_nil
      end
    end
  end

  describe "#ancestors" do
    context "when there are ancestors" do
      let(:a) { create(:request_for_help_category, slug: "a") }
      let(:b) { create(:request_for_help_category, slug: "b", parent: a) }
      let(:c) { create(:request_for_help_category, slug: "c", parent: b) }

      it "returns the ancestors" do
        expect(c.ancestors).to eq [a, b]
      end
    end

    context "when there are no ancestors" do
      let(:a) { create(:request_for_help_category, slug: "a") }

      it "returns an empty array" do
        expect(a.ancestors).to eq []
      end
    end
  end

  describe "#hierarchy" do
    context "when there are ancestors" do
      let(:a) { create(:request_for_help_category, slug: "a") }
      let(:b) { create(:request_for_help_category, slug: "b", parent: a) }
      let(:c) { create(:request_for_help_category, slug: "c", parent: b) }

      it "returns the entire hierarchy" do
        expect(c.hierarchy).to eq [a, b, c]
      end
    end

    context "when there are no ancestors" do
      let(:a) { create(:request_for_help_category, slug: "a") }

      it "returns current category" do
        expect(a.hierarchy).to eq [a]
      end
    end
  end

  describe "#is_descendant_of?" do
    let(:a) { create(:request_for_help_category, slug: "a") }
    let(:b) { create(:request_for_help_category, slug: "b", parent: a) }
    let(:c) { create(:request_for_help_category, slug: "c", parent: b) }

    context "when the category is a descendant of the given category" do
      it "returns true" do
        expect(c.is_descendant_of?(a)).to eq true
      end
    end

    context "when the category is not a descendant of the given category" do
      it "returns false" do
        expect(b.is_descendant_of?(c)).to eq false
      end
    end
  end

  describe "#find_next_in_hierarchy_to" do
    let(:a) { create(:request_for_help_category, slug: "a") }
    let(:b) { create(:request_for_help_category, slug: "b", parent: a) }
    let(:c) { create(:request_for_help_category, slug: "c", parent: b) }
    let(:d) { create(:request_for_help_category, slug: "d", parent: c) }

    context "when there are intermediate categories" do
      it "returns the next one line" do
        expect(a.find_next_in_hierarchy_to(d)).to eq b
      end
    end

    context "when there are no intermediate categories" do
      it "returns the last category" do
        expect(b.find_next_in_hierarchy_to(c)).to eq c
      end
    end

    context "when there is no hierarchy" do
      let(:x) { create(:request_for_help_category, slug: "x") }

      it "returns nil" do
        expect(d.find_next_in_hierarchy_to(x)).to be_nil
      end
    end
  end

  describe "#root_parent" do
    context "when there are no ancestors" do
      let(:a) { create(:request_for_help_category, slug: "a") }

      it "returns itself" do
        expect(a.root_parent).to eq a
      end
    end

    context "when there are ancestors" do
      let(:a) { create(:request_for_help_category, slug: "a") }
      let(:b) { create(:request_for_help_category, slug: "b", parent: a) }
      let(:c) { create(:request_for_help_category, slug: "c", parent: b) }

      it "returns the root parent" do
        expect(c.root_parent).to eq a
      end
    end
  end

  describe "#other?" do
    let(:category) { create(:request_for_help_category, slug:) }

    context "when the category slug is other" do
      let(:slug) { "other" }

      it "returns true" do
        expect(category.other?).to eq true
      end
    end

    context "when the category slug is not other" do
      let(:slug) { "stuff" }

      it "returns false" do
        expect(category.other?).to eq false
      end
    end
  end
end
