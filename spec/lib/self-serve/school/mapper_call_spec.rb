require "school/mapper"

RSpec.describe School::Mapper, "#call" do
  subject(:mapper) { described_class.new }

  let(:entity) { output.first[key] }

  # The public GIAS "edubasealldata" CSV file is a historical cummulative record.
  # Consequently there are multiple entries for the same EstablishmentName if
  # that establishment's status, type or laocation have changed over time.
  #
  let(:output) do
    mapper.call(
      [
        {
          # 6 digit integer - establishment                                     # Column
          "URN" => "136899", # A:
          # local_authority
          "LA (code)" => "919",                                                 # B:
          "LA (name)" => "Hertfordshire",                                       # C:
          # school
          "EstablishmentNumber" => "5404",                                      # D: not unique, geographically disparate
          "EstablishmentName" => "Parmiter's School",                           # E:
          # establishment_type
          "TypeOfEstablishment (code)" => "34",                                 # F:
          "TypeOfEstablishment (name)" => "Academy converter",                  # G:
          # establishment_type_group
          "EstablishmentTypeGroup (code)" => "10",                              # H:
          "EstablishmentTypeGroup (name)" => "Academies",                       # I:
          # establishment_status
          "EstablishmentStatus (code)" => "1",                                  # J:
          "EstablishmentStatus (name)" => "Open",                               # K:
          # constituency
          "ParliamentaryConstituency (name)" => "Cities of London & Westminster",
          "ParliamentaryConstituency (code)" => "E14000639",
          # district
          "DistrictAdministrative (name)" => "City of London",
          "DistrictAdministrative (code)" => "E09000001",
          # ward
          "AdministrativeWard (name)" => "King's Cross",
          "AdministrativeWard (code)" => "E05009308",
          # federation
          # 4 to 5 digit integer
          "Federations (code)" => "1473", # AY:
          "Federations (name)" => "The Viridis Federation of Orchard, Southwold & Hoxton Garden Primary Schools", # AZ:
          # phase
          "PhaseOfEducation (code)" => "4",                                     # R:
          "PhaseOfEducation (name)" => "Secondary",                             # S:
          # age
          "StatutoryLowAge" => "11",                                            # T:
          "StatutoryHighAge" => "18",                                           # U:
          # boarding
          "Boarders (code)" => "3",                                             # V:
          "Boarders (name)" => "Boarding School",                               # W:
          # gender
          "Gender (code)" => "1",                                               # AA:
          "Gender (name)" => "Mixed",                                           # AB:
          # religion
          "ReligiousCharacter (code)" => "2",                                   # AC:
          "ReligiousCharacter (name)" => "Church of England",                   # AD:
          # Trust
          "Trusts (name)" => "Cool Green School Trust", # AU:
          "Trusts (code)" => "Cool Green School Trust CODE", # AT:
          "GOR (name)" => "GOR NAME", # CZ:

          "SchoolCapacity" => "100",
          "NumberofPupils" => "101",

          # 8 digit integer - organisation
          "UKPRN" => "117576", # BA:
          # 7 to 12 digit integer
          "UPRN" => "100005",

          "OfstedLastInsp" => "02-07-2021", # BD:
          "OfstedRating (name)" => "Outstanding",

          # head
          "HeadTitle (name)" => "Dr.",
          "HeadFirstName" => "A. B.",
          "HeadLastName" => "Testing",
          "HeadPreferredJobTitle" => "Acting Headteacher",
          # address
          "Street" => "High Elms Lane",                                         # BH:
          "Locality" => "Garston",                                              # BI:
          "Town" => "Watford",                                                  # BK:
          "County (name)" => "Hertfordshire",                                   # BL:
          "Postcode" => "WD25 0UU",                                             # BM:
          # contact (integer dropped leading zero)
          "SchoolWebsite" => "http://www.parmiters.herts.sch.uk",               # BN:
          "TelephoneNum" => "1923671424",                                       # BO:

          # special_needs_support
          "SEN1 (name)" => "MLD - Moderate Learning Difficulty",                # CG:
          "SEN2 (name)" => "PD - Physical Disability",                          # CH:
          "SEN3 (name)" => "ASD - Autistic Spectrum Disorder",                  # CI:
          "SEN4 (name)" => "SLCN - Speech, language and Communication",         # CJ:
          "SEN5 (name)" => "SEMH - Social, Emotional and Mental Health",        # CK:
          "SEN6 (name)" => "HI - Hearing Impairment",                           # CL:
          "SEN7 (name)" => "VI - Visual Impairment",                            # CM:
          "SEN8 (name)" => "",
          "SEN9 (name)" => "",
          "SEN10 (name)" => "",
          "SEN11 (name)" => "",
          "SEN12 (name)" => "",
          "SEN13 (name)" => "",

          # MAT/SAT registered company
          "CHNumber" => "",                                                     # EG:

        },
      ],
    )
  end

  describe "special_needs_support" do
    let(:key) { :special_needs_support }

    specify do
      expect(entity).to eql([
        "ASD - Autistic Spectrum Disorder",
        "HI - Hearing Impairment",
        "MLD - Moderate Learning Difficulty",
        "PD - Physical Disability",
        "SEMH - Social, Emotional and Mental Health",
        "SLCN - Speech, language and Communication",
        "VI - Visual Impairment",
      ])
    end
  end

  describe "ward" do
    let(:key) { :ward }

    specify do
      expect(entity).to eql(name: "King's Cross", code: "E05009308")
    end
  end

  specify("trust_name") { expect(output.first[:school][:trust_name]).to eq("Cool Green School Trust") }
  specify("trust_code") { expect(output.first[:school][:trust_code]).to eq("Cool Green School Trust CODE") }
  specify("gor_name")   { expect(output.first[:school][:gor_name]).to eq("GOR NAME") }

  describe "district" do
    let(:key) { :district }

    specify do
      expect(entity).to eql(name: "City of London", code: "E09000001")
    end
  end

  describe "federation" do
    let(:key) { :federation }

    specify do
      expect(entity).to eql(
        name: "The Viridis Federation of Orchard, Southwold & Hoxton Garden Primary Schools",
        code: "1473",
      )
    end
  end

  describe "constituency" do
    let(:key) { :constituency }

    specify do
      expect(entity).to eql(name: "Cities of London & Westminster", code: "E14000639")
    end
  end

  describe "local authority" do
    let(:key) { :local_authority }

    specify do
      expect(entity).to eql(name: "Hertfordshire", code: "919")
    end
  end

  describe "school" do
    let(:key) { :school }

    specify "address" do
      expect(entity[:address]).to eql(
        street: "High Elms Lane",
        locality: "Garston",
        town: "Watford",
        county: "Hertfordshire",
        postcode: "WD25 0UU",
      )
    end
  end
end
