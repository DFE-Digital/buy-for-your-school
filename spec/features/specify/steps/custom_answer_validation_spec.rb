RSpec.feature "Custom question validation" do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:journey) { create(:journey, category:, user:) }
  let(:section) { create(:section, journey:) }
  let(:task) { create(:task, section:) }

  before do
    user_is_signed_in(user:)
    create(:step, question_type, task:, title:, criteria:)
    visit_journey
    within ".app-task-list" do
      click_on "Task title"
    end
  end

  describe "number" do
    let(:question_type) { :number }
    let(:title) { "count" }
    let(:criteria) do
      {
        "message": "too few/many",
        "lower": "69",
        "upper": "70",
      }
    end

    specify do
      expect(find("label.govuk-label--l")).to have_content "count"
    end

    context "when criteria ar omitted" do
      let(:criteria) { nil }

      it "ignores validation" do
        fill_in "answer[response]", with: "69"
        click_continue

        expect(find("strong.app-task-list__tag")).to have_text "Completed"
      end
    end

    context "when within bounds" do
      it "passes validation" do
        fill_in "answer[response]", with: "69"
        click_continue

        expect(find("strong.app-task-list__tag")).to have_text "Completed"
      end
    end

    context "when out of bounds" do
      it "renders the custom error message" do
        fill_in "answer[response]", with: "123"
        click_continue

        expect(find(".govuk-error-message")).to have_text "too few/many"
      end
    end
  end

  describe "currency" do
    let(:question_type) { :currency }
    let(:title) { "cost" }
    let(:criteria) do
      {
        "message": "too cheap/expensive",
        "lower": "1000.0",
        "upper": "1999.01",
      }
    end

    specify do
      expect(find("label.govuk-label--l")).to have_content "cost"
    end

    context "when within bounds" do
      it "passes validation" do
        fill_in "answer[response]", with: "1001"
        click_continue

        expect(find("strong.app-task-list__tag")).to have_text "Completed"
      end
    end

    context "when out of bounds" do
      it "renders the custom error message" do
        fill_in "answer[response]", with: "2001"
        click_continue

        expect(find(".govuk-error-message")).to have_text "too cheap/expensive"
      end
    end
  end

  # TODO: Use Chronic gem for "18 years from now"
  describe "single_date" do
    let(:question_type) { :single_date }
    let(:title) { "date of birth" }
    let(:criteria) do
      {
        "message": "too young/old",
        "lower": "1900-01-01 12:34",
        "upper": "2000-01-01 00:01",
      }
    end

    specify do
      expect(find("legend.govuk-fieldset__legend--l")).to have_content "date of birth"
    end

    context "when within bounds" do
      it "passes validation" do
        fill_in "answer[response(3i)]", with: "30"
        fill_in "answer[response(2i)]", with: "6"
        fill_in "answer[response(1i)]", with: "1981"
        click_continue

        expect(find("strong.app-task-list__tag")).to have_text "Completed"
      end
    end

    context "when out of bounds" do
      it "renders the custom error message" do
        fill_in "answer[response(3i)]", with: "30"
        fill_in "answer[response(2i)]", with: "6"
        fill_in "answer[response(1i)]", with: "3001"
        click_continue

        expect(find(".govuk-error-message")).to have_text "too young/old"
      end
    end
  end
end
