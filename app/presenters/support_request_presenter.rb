# Helpers for a support request to display information on the page
class SupportRequestPresenter < SimpleDelegator
  def email
    user&.email
  end
end
