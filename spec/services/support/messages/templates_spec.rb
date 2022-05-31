describe Support::Messages::Templates do
  subject(:service) { described_class }

  let(:params) do
    {
      body: "This is a test message",
      agent: "Test Agent",
    }
  end

  it "applies parameters to the basic signature template" do
    template = service.new(params: params).call
    expect(template).to eq "<p>This is a test message</p>\n<p>Regards<br>Test Agent<br>Procurement Specialist<br>Get help buying for schools</p>\n"
  end
end
