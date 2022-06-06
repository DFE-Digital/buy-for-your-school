module ClamavRest
  class MockScanner
    def initialize(is_safe:)
      @is_safe = is_safe
    end

    def file_is_safe?(_file)
      @is_safe
    end
  end
end
