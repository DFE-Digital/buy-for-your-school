describe FrameworkRequests::SignInForm, type: :model do
  subject(:form) { described_class.new }

  describe "validation" do
    describe "dsi" do
      it { is_expected.to validate_presence_of(:dsi) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:dsi]).to eq ["Select whether you want to use a DfE Sign-in account"]
        end
      end
    end
  end
end
