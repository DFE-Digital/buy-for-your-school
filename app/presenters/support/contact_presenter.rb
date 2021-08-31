module Support
  class ContactPresenter < BasePresenter
    def name
      "#{format_name(first_name)} #{format_name(last_name)}"
    end
  end
end
