module Support
  class DownloadContractHandover < ApplicationRecord
    belongs_to :support_case, class_name: "Support::Case"
  end
end
