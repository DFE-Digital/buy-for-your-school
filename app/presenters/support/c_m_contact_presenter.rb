# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class CMContactPresenter < BasePresenter
    def name
      "#{format_name(first_name)} #{format_name(last_name)}"
    end
  end
end
# :nocov: