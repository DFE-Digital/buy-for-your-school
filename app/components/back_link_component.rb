# frozen_string_literal: true

class BackLinkComponent < ViewComponent::Base
  def initialize(url:)
    @url = url
  end
end
