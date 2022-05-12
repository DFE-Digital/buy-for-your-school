require_relative "configuration"
require_relative "scanner"
require_relative "mock_scanner"

module ClamavRest
  def self.get_scanner_strategy=(callable)
    @get_scanner_strategy = callable
  end

  def self.get_scanner_strategy
    @get_scanner_strategy || -> { nil }
  end

  def self.scanner=(scanner)
    @scanner = scanner
  end

  def self.scanner
    @scanner || @get_scanner_strategy.call
  end
end
