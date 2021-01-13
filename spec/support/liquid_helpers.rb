module LiquidHelpers
  def stub_liquid_template(filename: "basic_catering.liquid")
    fake_liquid_template = File.read("#{Rails.root}/spec/fixtures/specification_templates/#{filename}")

    finder = instance_double(FindLiquidTemplate)
    allow(FindLiquidTemplate).to receive(:new).with(category: "catering")
      .and_return(finder)
    allow(finder).to receive(:call).and_return(fake_liquid_template)

    fake_liquid_template
  end
end
