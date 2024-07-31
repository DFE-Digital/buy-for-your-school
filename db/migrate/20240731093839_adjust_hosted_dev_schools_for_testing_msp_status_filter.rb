class AdjustHostedDevSchoolsForTestingMspStatusFilter < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://dev.get-help-buying-for-schools.service.gov.uk"
      # Change United Learning Trust's following schools:
      # Accrington Academy URN 135649, from status 1 (opened) to 2 (closed)
      school = Support::Organisation.find_by(urn: "135649")
      if school.present?
        school.update!(status: :closed)
      end

      # Avonbourne Girls Academy URN 138193, from status 1 (opened) to 3 (closing)
      school = Support::Organisation.find_by(urn: "138193")
      if school.present?
        school.update!(status: :closing)
      end

      # Bacon's College URN 145313 from status 1 (opened) to 4 (opening)
      school = Support::Organisation.find_by(urn: "145313")
      if school.present?
        school.update!(status: :opening)
      end      
    end
  end

  def down
    if ENV["APPLICATION_URL"] == "https://dev.get-help-buying-for-schools.service.gov.uk"
      # Change United Learning Trust's following schools:
      # Accrington Academy URN 135649, back to status 1 (opened) from 2 (closed)
      school = Support::Organisation.find_by(urn: "135649")
      if school.present?
        school.update!(status: :opened)
      end

      # Avonbourne Girls Academy URN 138193, back to status 1 (opened) from 3 (closing)
      school = Support::Organisation.find_by(urn: "138193")
      if school.present?
        school.update!(status: :opened)
      end

      # Bacon's College URN 145313 back to status 1 (opened) from 4 (opening)
      school = Support::Organisation.find_by(urn: "145313")
      if school.present?
        school.update!(status: :opened)
      end      
    end
  end
end
