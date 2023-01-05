module FrameworkRequests
  class SignInForm < BaseForm
    validates :dsi, presence: true
  end
end
