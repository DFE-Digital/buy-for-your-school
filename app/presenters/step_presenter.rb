class StepPresenter < SimpleDelegator
  def question?
    contentful_model == "question"
  end
end
