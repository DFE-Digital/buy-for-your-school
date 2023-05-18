module Support
  module ExpanderHelper
    def expander(title:, subtitle: nil, expanded: false, disabled: false, html: nil, &block)
      render "support/helpers/expander", title:, subtitle:, expanded:, disabled:, html:, content: capture(&block)
    end
  end
end
