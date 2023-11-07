module Frameworks::Evaluation::Sourceable
  extend ActiveSupport::Concern

  included do
    attr_accessor :source

    enum :creation_source, { default: 0, transfer: 1 }, prefix: true
  end
end
