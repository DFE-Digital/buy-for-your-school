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
            sub_value = Rails::Html::FullSanitizer.new.sanitize(sub_value)
          end
          sub_value
        end
      elsif value.is_a?(String)
        value = Rails::Html::FullSanitizer.new.sanitize(value)
      end

      value
    end
  end
end
