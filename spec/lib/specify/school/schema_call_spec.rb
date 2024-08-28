require "school/schema"

RSpec.describe School::Schema, "#call" do
  subject(:schema) { described_class.new }

  let(:result) { schema.call(input) }

  let(:input) do
    {
      local_authority: {
        code: "919",
        name: "Hertfordshire",
      },
      district: {
        code: "E09000001",
        name: "City of London",
      },
      federation: {
        code: "1473",
        name: "The Viridis Federation of Orchard, Southwold & Hoxton Garden Primary Schools",
      },
      ward: {
        code: "E05009308",
        name: "King's Cross",
      },
      constituency: {
        code: "E14000639",
        name: "Cities of London and Westminster",
      },
      establishment_type: {
        code: "34",
        name: "Academy converter",
      },
      establishment_type_group: {
        code: "10",
        name: "Academies",
      },
      establishment_status: {
        code: "1",
        name: "Open",
      },

      ukprn: "117576",
      uprn: "100005",
      urn: "136899",
      crn: "",
      rsc_region: "North-West England",

      # SCHOOL (establishment)
      school: {
        name: "Parmiter's School",
        number: "5404",
        ofsted_rating: "Outstanding",
        ofsted_last_inspection: "02-07-2021",
        student_capacity: "100",
        student_number: "101",
        website: "http://www.parmiters.herts.sch.uk",
        telephone_number: "1923671424",
        opened_date: "01-01-1980",
        phase: {
          code: "4",
          name: "Secondary",
        },
        religion: {
          code: "4",
          name: "Secondary",
        },
        gender: {
          code: "1",
          name: "Mixed",
        },
        gor_name: "GOR NAME",
        age: {
          lower: "11",
          upper: "18",
        },
        head_teacher: {
          role: "Acting Headteacher",
          title: "Dr.",
          first_name: "A. B.",
          last_name: "Testing",
        },
        address: {
          street: "High Elms Lane",
          locality: "Garston",
          town: "Watford",
          county: "Hertfordshire",
          postcode: "WD25 0UU",
        },
        trust_name: "Test Trust Name",
        trust_code: "Test Trust Code",
        closed_date: "31/03/2017",
        reason_establishment_opened: "New Provision",
        reason_establishment_closed: "Transferred to new sponsor",
      },
    }
  end

  it do
    expect(result.errors.to_h).to be_empty
  end
end
