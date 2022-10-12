require "school/record_keeper"

RSpec.describe School::RecordKeeper do
  subject(:record_keeper) { described_class.new }

  let(:legacy_record) do
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
        code: 34,
        name: "Academy converter",
      },
      establishment_type_group: {
        code: "10",
        name: "Academies",
      },
      establishment_status: {
        code: 2,
        name: "Closed",
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
          code: 4,
          name: "Secondary",
        },
        religion: {
          code: 4,
          name: "Secondary",
        },
        gender: {
          code: 1,
          name: "Mixed",
        },
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
        trust_name: "Legacy School Trust Name"
      },
    }
  end

  let(:new_record) do
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
        code: 34,
        name: "Academy converter",
      },
      establishment_type_group: {
        code: "10",
        name: "Academies",
      },
      establishment_status: {
        code: 1,
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
        opened_date: "01-09-2021",
        phase: {
          code: 4,
          name: "Secondary",
        },
        religion: {
          code: 4,
          name: "Secondary",
        },
        gender: {
          code: 1,
          name: "Mixed",
        },
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
        trust_name: "New School Trust Name"
      },
    }
  end

  let(:saved_keys) do
    %i[ establishment_type_id
        name
        address
        contact
        phase
        gender
        status
        number
        rsc_region
        local_authority
        opened_date
        ukprn
        telephone_number
        trust_name]
  end

  describe "#call" do
    context "with a set of records including a record for a closed and opened organisation" do
      before { create(:support_establishment_type, code: 34) }

      it "persists the opened organisation" do
        expect { record_keeper.call([legacy_record, new_record]) }.to change(Support::Organisation, :count).by(1)
        expect(Support::Organisation.last.urn).to eq(new_record[:urn])
      end

      it "saves data to the fields chosen" do
        record_keeper.call([legacy_record, new_record])

        saved_keys.each do |key|
          expect(Support::Organisation.last.send(key).blank?).to be(false)
        end
      end
    end
  end
end
