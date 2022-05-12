require_relative "configuration"
require_relative "scanner"
require_relative "mock_scanner"

module ClamavRest
  def self.scanner=(scanner)
    @scanner = scanner
  end

  def self.scanner
    @scanner || @get_scanner_strategy.call
  end
end
