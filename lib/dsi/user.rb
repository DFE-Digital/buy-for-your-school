# frozen_string_literal: true

require "dry-initializer"
require "types"

module Dsi
  #
  # {
  #     "approvedAt": "2019-06-19T15:09:58.683Z",
  #     "updatedAt": "2019-06-19T15:09:58.683Z",
  #     "organisation": {
  #         "id": "13F20E54-79EA-4146-8E39-18197576F023",
  #         "name": "Department for Education",
  #         "Category": "002",
  #         "Type": null,
  #         "URN": null,
  #         "UID": null,
  #         "UKPRN": null,
  #         "EstablishmentNumber": "001",
  #         "Status": 1,
  #         "ClosedOn": null,
  #         "Address": null,
  #         "phaseOfEducation": null,
  #         "statutoryLowAge": null,
  #         "statutoryHighAge": null,
  #         "telephone": null,
  #         "regionCode": null,
  #         "legacyId": "1031237",
  #         "companyRegistrationNumber": "1234567",
  #         "createdAt": "2019-02-20T14:27:59.020Z",
  #         "updatedAt": "2019-02-20T14:28:38.223Z"
  #     },
  #     "roleName": "Approver",
  #     "roleId": 10000,
  #     "userId": "21D62132-6570-4E63-9DCB-137CC35E7543",
  #     "email": "foo@example.com",
  #     "familyName": "Johnson",
  #     "givenName": "Roger"
  # }
  class User
    extend Dry::Initializer

    option :user, Types::Hash

    def uid
      user["userId"]
    end

    def first_name
      user["givenName"]
    end

    def last_name
      user["familyName"]
    end

    def email
      user["email"]
    end

    def updated_at
      user["updatedAt"]
    end

    def approved_at
      user["approvedAt"]
    end

    def organisation_id
      user["organisation"]["id"]
    end

    def organisation_name
      user["organisation"]["name"]
    end

    def organisation_ukprn
      user["organisation"]["UKPRN"]
    end

    def organisation_crn
      user["organisation"]["companyRegistrationNumber"]
    end

    # @return [String] "002 (Local Authority)
    #
    # @see https://github.com/DFE-Digital/login.dfe.public-api#how-do-ids-map-to-categories-and-types
    #
    def organisation_category
      user["organisation"]["Category"]
    end

    # @return [String] "001" (Community School)
    #
    # @see https://github.com/DFE-Digital/login.dfe.public-api#establishment-types
    #
    def organisation_establishment_number
      user["organisation"]["EstablishmentNumber"]
    end

    def role_name
      user["roleName"]
    end

    def role_id
      user["roleId"]
    end
  end
end
