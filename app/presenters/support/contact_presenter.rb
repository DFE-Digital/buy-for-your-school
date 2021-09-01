module Support
  class ContactPresenter < BasePresenter
    # @return [String]
    def full_name
      [format_name(first_name), format_name(last_name)].join(' ')
    end
  end
end
