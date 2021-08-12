RSpec.feature "Expected tasks are visible" do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:journey) { create(:journey, user: user, category: category) }
  let(:section) { create(:section, journey: journey) }

  before do
    user_is_signed_in(user: user)
  end

  context "when a task has one step" do
    context "and it is a question" do
      before do
        single_question_task = create(:task, title: "Single question task", section: section)
        create(:step, :number, task: single_question_task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "Single question task"
        end
      end
    end

    context "and it is a statement" do
      before do
        single_statement_task = create(:task, title: "Single statement task", section: section)
        create(:step, :statement, task: single_statement_task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "Single statement task"
        end
      end
    end
  end

  context "when a task has multiple steps" do
    context "and all are questions" do
      before do
        all_question_task = create(:task, title: "All question task", section: section)
        create(:step, :number, task: all_question_task)
        create(:step, :number, task: all_question_task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "All question task"
        end
      end
    end

    context "and all are statements" do
      before do
        all_statement_task = create(:task, title: "All statement task", section: section)
        create(:step, :statement, task: all_statement_task)
        create(:step, :statement, task: all_statement_task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "All statement task"
        end
      end
    end

    context "and there are questions and statements" do
      before do
        mixed_task = create(:task, title: "Mixed task", section: section)
        create(:step, :number, task: mixed_task)
        create(:step, :statement, task: mixed_task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "Mixed task"
        end
      end
    end
  end
end
