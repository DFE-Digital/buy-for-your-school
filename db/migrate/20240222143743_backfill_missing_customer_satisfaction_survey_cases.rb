class BackfillMissingCustomerSatisfactionSurveyCases < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      survey_to_case_map = {
        "3b546ce8-dc8d-45aa-8dae-20ccb364e264" => "715f8693-c039-4ff6-ae46-af5717239c72",
        "d93c644a-2e41-4978-bbf8-fd7d9fc0c36c" => "ad2d9fa5-951f-4106-a02a-4b49d2b9bfbc",
        "eadb265c-f3ec-49fc-b6d0-208db85c0e1c" => "e55b3a4c-13f1-4358-99e0-3795f67fed76",
        "f749f183-8dae-44c7-a223-ec9939e20ca7" => "dc54422e-a5c8-4af3-a0d1-60ad38bf7720",
        "6666b790-a0fd-4c54-a18c-98649d8b5c30" => "2165717a-24e1-4a70-a8f4-24be0ce01a60",
        "d91ec0bb-c0c8-440d-9558-9341d173ca8a" => "b2675744-9fbd-4593-b196-9bcd6f0352de",
        "2aaebfca-c223-47f6-8af5-adaee4b0c97b" => "fab05ecc-8ac2-445a-b974-2aa940931a0b",
        "bd81748e-ff92-4dea-84f2-02b11d87712e" => "bd0bacc6-0d26-4393-98f2-ddebba4872c4",
        "18538a3e-1a4e-40cb-8d04-548286636cec" => "dc9d1256-1d47-47cc-951a-0f7c59590405",
        "07913eb6-c65c-4e7f-8135-48f12e430146" => "3bc3fd2f-a2e5-4100-ab17-f4547111a8ae",
        "ee8d9db4-dc52-41d7-b00c-1a720107063b" => "9f9ebe22-9cef-465c-9907-1292b97526bb",
        "e5ef0618-56a9-4846-94fb-e56165eff579" => "9739d87d-61e1-4928-ac05-33e7660ea569",
        "9c9e5e4a-f166-4c71-9209-c56d3b5b4cd0" => "4e027643-c860-4b0b-88c5-0eec3cae7387",
        "141dc343-4686-425e-97fd-c29ca4a1e8a8" => "c49a921d-9de4-41b5-96b7-a9513f28650f",
        "87a38bb6-6a1a-4d5d-84b1-265c749e219a" => "1c3c1cf8-2b69-4f0d-8665-f5d7a45f1d7b",
        "ccdd73d6-d6d0-491d-93de-5224bf65dd9b" => "f9f9ea4e-dce6-480b-bf4d-16079988a390",
        "f0cdcc0d-a25d-416f-b35f-f7a928669368" => "e177d61d-4428-4736-84c4-bf9bb46812c6",
        "6fbfc439-0b5b-4ca1-8292-ede53f0e4d81" => "d7e46c16-b3d7-48a5-93ae-74b5496bdc40",
        "2451a840-cedd-45fd-91f5-15d264da6dbc" => "e5086728-b4a2-4532-878a-c31f46731681",
        "036216d8-8af9-4348-b8cb-5748af07a21b" => "f361a64d-e626-4425-a383-465d0a778516",
        "83d9e736-3777-4a93-8ec0-5e5bfef8e415" => "31274c56-4384-4a80-aedc-af555109f583",
        "b180a00c-233c-4058-a5e8-5116896e91dd" => "ba7df5db-d089-4dc7-b772-b41055e8225a",
        "aebec487-4636-486d-8de9-855c93d90c6c" => "40a1b534-0d8e-4e39-b028-d9c1515ae910",
        "c0edcc68-5610-420a-9d78-2eafff77f2c8" => "42bac14c-b374-43d6-89a8-c6eba60ee008",
        "f3554baa-2b5a-4437-98dd-760f0ba4029d" => "f1b99a69-3d98-4c60-a48e-f816c0f4aed0",
      }

      survey_to_case_map.each do |survey_id, kase_id|
        survey = CustomerSatisfactionSurveyResponse.find_by(id: survey_id)
        survey.update!(support_case_id: kase_id) if survey.present? && survey.support_case_id.nil?
      end
    end
  end

  def down; end
end
