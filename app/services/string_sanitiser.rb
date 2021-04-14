class StringSanitiser
  attr_accessor :args
  def initialize(args:)
    self.args = args
  end

  def call
    args.deep_merge(args) do |_, _, value|
      if value.is_a?(Array)
        value = value.map do |sub_value|
          if sub_value.is_a?(String)
            sub_value = sanitize(sub_value)
          end
          sub_value
        end
      elsif value.is_a?(String)
        value = sanitize(value)
      end

      value
    end
  end

  private def sanitize(value)
    safe_list_sanitizer = Rails::Html::SafeListSanitizer.new
    safe_list_sanitizer.sanitize(value, tags: allowed_html_tags)
  end

  private def allowed_html_tags
    %w[p b i]
  end
end
