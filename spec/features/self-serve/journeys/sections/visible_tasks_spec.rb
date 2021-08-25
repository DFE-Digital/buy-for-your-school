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
        task = create(:task, title: "Task with single question", section: section)
        create(:step, :number, task: task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "Task with single question"
        end
      end
    end

    context "and it is a statement" do
      before do
        task = create(:task, title: "Task with single statement", section: section)
        create(:step, :statement, task: task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "Task with single statement"
        end
      end
    end
  end

  context "when a task has multiple steps" do
    context "and all are questions" do
      before do
        task = create(:task, title: "Task with only questions", section: section)
        create(:step, :number, task: task)
        create(:step, :number, task: task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "Task with only questions"
        end
      end
    end

    context "and all are statements" do
      before do
        task = create(:task, title: "Task with only statements", section: section)
        create(:step, :statement, task: task)
        create(:step, :statement, task: task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "Task with only statements"
        end
      end
    end

    context "and there are questions and statements" do
      before do
        task = create(:task, title: "Task with questions and statements", section: section)
        create(:step, :number, task: task)
        create(:step, :statement, task: task)
        visit "/journeys/#{journey.id}"
      end

      it "is visible" do
        within "ul.app-task-list__items" do
          expect(find("a.govuk-link")).to have_text "Task with questions and statements"
        end
      end
    end
  end
end
