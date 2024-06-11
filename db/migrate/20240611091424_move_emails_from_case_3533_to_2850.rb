class MoveEmailsFromCase3533To2850 < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      threads_to_move =
        [
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAAE1pFpGL6xKpxxI5DlVhFM=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAB69uoF7YsVEkbY_5LNuqzM=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQACGyc0lWylRMntNHj5PVyMo=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQADrl22xgN0luhjAY04tE1aI=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAE8c7aQkR0FBlX6jNCmJVyk=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAEaYqG4gFApLhCQjf6Voj0c=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAEm_RlcaSUR5kLxWlnXk_nQ=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAF8792jhinJMu4i7YdBCF1w=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAFOoMpIJ2UqXnuoNkoSZ-SY=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAG7K9yYqg-pDrrufZ_YVkps=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAG8qtPkDntxIiB2N7tXGUzQ=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAGbAnzlmjVBHkEKxsO7H4Yc=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAGFUmnV9O0bzvuvTzRqss-c=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAGk68h1BdYROjf7v6ZBYzdE=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAHOQ6YfH3OhDv1Kfieo2olU=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAHptW4sE6cZJiCusghyhJeA=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAIJAGX0ynnVMop3DGgq1on0=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAIU0y9pAzkeKnpiQ4AIAxMo=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAKfNJUCfF6dOupzIEhOvpJc=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAL5fgT7Tf0g0jiCzxaV1olg=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQALTUlzOCR0WvpyYPzxmcAKc=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQALV19c65t0x4kJyf_cTZXfo=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQALZAFIQ4o02Xj2C8dWq1D_4=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAN10xqdcBs9FomrT-PVanqs=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAN4IGURwB_FBl608imG7AFk=",
          "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQANMsv5sYF038uyewOjJW_aE=",
        ]
      target_case = Support::Case.find_by(ref: "002850")
      return if target_case.nil?

      threads_to_move.each do |outlook_conversation_id|
        emails = Email.where(outlook_conversation_id:)
        next if emails.empty?

        emails.each do |email|
          next if email.ticket_id == target_case.id

          email.update!(ticket_id: target_case.id)
        end
      end
    end
  end

  def down; end
end
