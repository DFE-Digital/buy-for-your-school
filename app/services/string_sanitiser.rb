# Permit only paragraph, bold and italic HTML tags
#
class StringSanitiser
  attr_accessor :args

  def initialize(args:)
    self.args = args
  end

  def call
    args.deep_merge(args) do |_, _, value|
      case value
      when Array
        value = value.map do |sub_value|
          sub_value = sanitize(sub_value) if sub_value.is_a?(String)
          sub_value
        end
      when String
        value = sanitize(value)
      end

      value
    end
  end

private

  def sanitize(value)
    safe_list_sanitizer = Rails::Html::SafeListSanitizer.new
    safe_list_sanitizer.sanitize(value, tags: allowed_html_tags)
  end

  def allowed_html_tags
    %w[p b i]
  end
end
