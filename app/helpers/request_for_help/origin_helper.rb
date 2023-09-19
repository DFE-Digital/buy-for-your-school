module RequestForHelp
  module OriginHelper
    def available_origins
      I18nOption.from("faf.origin.options.%%key%%", FrameworkRequest.origins.keys)
    end
  end
end
