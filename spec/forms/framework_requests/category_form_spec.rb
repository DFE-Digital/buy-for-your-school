describe FrameworkRequests::CategoryForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id, category_path:, category_slug:, category_other: form_category_other) }

  let(:framework_request) { create(:framework_request, category:, category_other:) }
  let(:category) { nil }
  let(:category_path) { nil }
  let(:category_slug) { nil }
  let(:category_other) { nil }
  let(:form_category_other) { nil }

  let(:ict) { create(:request_for_help_category, slug: "ict", title: "ICT", description: nil) }
  let(:hardware) { create(:request_for_help_category, slug: "hardware", title: "Hardware", parent: ict) }
  let!(:laptops) { create(:request_for_help_category, slug: "laptops", title: "Laptops", parent: hardware) }

  let(:energy) { create(:request_for_help_category, slug: "energy", title: "Energy", description: "energy category") }
  let!(:solar) { create(:request_for_help_category, slug: "solar", title: "Solar", description: nil, parent: energy) }
  let!(:gas) { create(:request_for_help_category, slug: "gas", title: "Gas", description: nil, parent: energy) }
  let!(:other) { create(:request_for_help_category, slug: "other", title: "Other", description: nil, parent: energy) }

  describe "validation" do
    describe "category_slug" do
      it { is_expected.to validate_presence_of(:category_slug) }

      context "when no category_slug is provided" do
        let(:category_slug) { nil }

        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:category_slug]).to eq ["Select the type of goods or service you need"]
        end
      end
    end

    describe "category_other" do
      context "when 'other' category is chosen and no description is provided" do
        let(:category_slug) { "other" }
        let(:category_other) { nil }

        it { is_expected.to validate_presence_of(:category_other) }

        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:category_other]).to eq ["Specify the type of goods or service you need"]
        end
      end
    end
  end

  describe "on initialization" do
    let(:category) { laptops }

    describe "category" do
      context "when a new category path is chosen" do
        let(:category_path) { "energy" }
        let(:category_slug) { "solar" }

        it "returns newly chosen category" do
          expect(form.category).to eq(solar)
        end
      end

      context "when a new category path is not chosen" do
        let(:category_path) { nil }
        let(:category_slug) { nil }

        it "returns existing category" do
          expect(form.category).to eq(laptops)
        end
      end
    end

    describe "current_category" do
      context "when a category path is provided" do
        let(:category_path) { "energy/gas" }

        it "returns the matching category" do
          expect(form.current_category).to eq(gas)
        end
      end

      context "when a category path is not provided" do
        let(:category_path) { nil }

        it "returns nil" do
          expect(form.current_category).to be_nil
        end
      end
    end

    describe "category_other" do
      context "when 'other' category text is provided" do
        let(:form_category_other) { "other requirements" }

        it "returns the 'other' text" do
          expect(form.category_other).to eq("other requirements")
        end
      end

      context "when 'other' category text is not provided" do
        let(:form_category_other) { nil }

        context "and 'other' category text already exists" do
          let(:category_other) { "existing other requirements" }

          it "returns existing 'other' text" do
            expect(form.category_other).to eq("existing other requirements")
          end
        end

        context "and 'other' category text does not exist" do
          let(:category_path) { nil }

          it "returns nil" do
            expect(form.category_other).to be_nil
          end
        end
      end
    end

    describe "enable_divider" do
      context "when the category path is not provided" do
        let(:category_path) { nil }

        it "returns true" do
          expect(form.enable_divider).to eq(true)
        end
      end

      context "when the category path is provided" do
        let(:category_path) { "ict" }

        it "returns false" do
          expect(form.enable_divider).to eq(false)
        end
      end
    end
  end

  describe "#category_options" do
    context "when the category path is 'multiple'" do
      let(:category_path) { "multiple" }

      it "returns nil" do
        expect(form.category_options).to be_nil
      end
    end

    context "when the category path is not provided" do
      let(:category_path) { nil }

      it "returns all top level categories" do
        expect(form.category_options).to contain_exactly(OpenStruct.new(slug: "ict", title: "ICT", description: nil, enable_conditional_content: false), OpenStruct.new(slug: "energy", title: "Energy", description: "energy category", enable_conditional_content: false))
      end
    end

    context "when the category path is provided" do
      let(:category_path) { "energy" }

      it "returns current category's subcategories" do
        expect(form.category_options).to contain_exactly(OpenStruct.new(slug: "solar", title: "Solar", description: nil, enable_conditional_content: false), OpenStruct.new(slug: "gas", title: "Gas", description: nil, enable_conditional_content: false), OpenStruct.new(slug: "other", title: "Other", description: nil, enable_conditional_content: true))
      end
    end
  end

  describe "#category_divider_options" do
    it "returns the 'multiple' option" do
      expect(form.category_divider_options).to contain_exactly(OpenStruct.new(slug: "multiple", title: "I'm buying more than one thing"))
    end
  end

  describe "#data" do
    let(:category_path) { "energy" }
    let(:category_slug) { "other" }
    let(:form_category_other) { "other energy needs" }

    it "returns attributes for persistence" do
      expect(form.data).to eq({
        category: other,
        category_other: "other energy needs",
      })
    end

    context "when category is not 'other'" do
      let(:category_slug) { "gas" }

      it "sets category_other to nil" do
        expect(form.data).to eq({
          category: gas,
          category_other: nil,
        })
      end
    end
  end

  describe "#new_path?" do
    context "when there is no existing category" do
      let(:category) { nil }

      it "returns true" do
        expect(form.new_path?).to eq(true)
      end
    end

    context "when there is an existing category" do
      let(:category) { laptops }

      context "and a category slug is provided" do
        context "and the slug is part of the same category hierarchy" do
          let(:category_slug) { "hardware" }

          it "returns false" do
            expect(form.new_path?).to eq(false)
          end
        end

        context "and the slug is part of a different category hierarchy" do
          let(:category_slug) { "solar" }

          it "returns true" do
            expect(form.new_path?).to eq(true)
          end
        end
      end

      context "and a category slug is not provided" do
        let(:category_slug) { nil }

        it "returns false" do
          expect(form.new_path?).to eq(false)
        end
      end
    end
  end

  describe "#set_selected_slug" do
    context "when the category slug is 'multiple'" do
      let(:category_slug) { nil }

      it "returns nil" do
        expect(form.set_selected_slug).to be_nil
      end
    end

    context "when a category is selected" do
      let(:category) { laptops }

      context "and the category path is nil" do
        let(:category_path) { nil }

        before { form.set_selected_slug }

        it "sets the top level parent slug" do
          expect(form.category_slug).to eq("ict")
        end
      end

      context "and the category path is within the existing category's hierarchy" do
        let(:category_path) { "ict" }

        before { form.set_selected_slug }

        it "sets the next category's slug" do
          expect(form.category_slug).to eq("hardware")
        end
      end

      context "and the category path is within the existing category's hierarchy (same level)" do
        let(:category_path) { "ict/hardware" }

        before { form.set_selected_slug }

        it "sets the existing category's slug" do
          expect(form.category_slug).to eq("laptops")
        end
      end

      context "and the category path is outside the existing category's hierarchy" do
        let(:category_path) { "energy" }

        before { form.set_selected_slug }

        it "sets the top level parent slug" do
          expect(form.category_slug).to eq("ict")
        end
      end
    end
  end

  describe "#parent_category_path" do
    let(:category_path) { "ict/hardware/laptops" }

    it "returns the current category's ancestor path" do
      expect(form.parent_category_path).to eq("ict/hardware")
    end
  end

  describe "#title" do
    context "when the category path is not provided" do
      let(:category_path) { nil }

      it "returns nil" do
        expect(form.title).to be_nil
      end
    end

    context "when the category path is provided" do
      let(:category_path) { "energy/solar" }

      it "returns humanized, uncapitalized category title" do
        expect(form.title).to eq("solar")
      end

      context "when the category title is a recognised acronym" do
        let(:category_path) { "ict" }

        it "returns humanized, all-capitalized category title" do
          expect(form.title).to eq("ICT")
        end
      end
    end
  end

  describe "#final_category?" do
    context "when the category slug is not 'multiple'" do
      context "and it has no subcategories" do
        let(:category_path) { "ict/hardware" }
        let(:category_slug) { "laptops" }

        it "returns true" do
          expect(form.final_category?).to eq(true)
        end
      end

      context "and it has subcategories" do
        let(:category_path) { "ict" }
        let(:category_slug) { "hardware" }

        it "returns false" do
          expect(form.final_category?).to eq(false)
        end
      end
    end

    context "when the category slug is 'multiple'" do
      let(:category_slug) { "multiple" }

      it "returns false" do
        expect(form.final_category?).to eq(false)
      end
    end
  end

  describe "#multiple_categories?" do
    context "when the category path is 'multiple'" do
      let(:category_path) { "multiple" }

      it "returns true" do
        expect(form.multiple_categories?).to eq(true)
      end
    end

    context "when the category path is not 'multiple'" do
      let(:category_path) { "ict" }

      it "returns false" do
        expect(form.multiple_categories?).to eq(false)
      end
    end
  end

  describe "#slugs" do
    let(:category_path) { "ict/hardware" }
    let(:category_slug) { "laptops" }

    it "returns the current path as a category path" do
      expect(form.slugs).to eq({ category_path: "ict/hardware/laptops" })
    end
  end

  describe "#current_path" do
    let(:category_path) { "ict/hardware" }
    let(:category_slug) { "laptops" }

    it "joins the give category path and slug" do
      expect(form.current_path).to eq("ict/hardware/laptops")
    end
  end

  describe "#other_category?" do
    context "when the category slug is 'other'" do
      let(:category_slug) { "other" }

      it "returns true" do
        expect(form.other_category?).to eq(true)
      end
    end

    context "when the category slug is not 'other'" do
      let(:category_slug) { "ict" }

      it "returns false" do
        expect(form.other_category?).to eq(false)
      end
    end
  end
end
