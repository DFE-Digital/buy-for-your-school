RSpec.shared_context "with awkward space characters" do
  let(:non_breaking_space) { "\u00A0" }
  let(:zero_width_space) { "\u200B" }
end
