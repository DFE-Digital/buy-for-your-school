require "rails_helper"

RSpec.describe Energy::Documents::LetterOfAuthority do
  it_behaves_like "attachable PDF", "DfE Energy for Schools Letter of Agreement"
end
