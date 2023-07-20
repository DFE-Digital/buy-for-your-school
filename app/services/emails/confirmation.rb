# frozen_string_literal: true

require "notify/email"

# @see https://www.notifications.service.gov.uk/services/73c59fe6-a823-49b9-888b-f3960c33b11c/templates/acb20822-a5eb-43a6-8607-b9c8e25759b4
#   subject: Thank you for your request for help with a specification
#   Hi ((first name))
#   We have received your request for support procuring ((category)) and will be in touch within 2 working days.
#   Your reference number is: ((case_ref)). Please quote this number when you speak to our team.
#   Your request: ((support query))
#
# @example "Auto-reply" template
#
#   Emails::Confirmation.new(
#     recipient: @user,
#     reference: "use case ref here"
#     template: "Auto-reply",
#     variables: {
#       support_query: "I have a problem",
#       category: "catering",
#       case_ref: "001",
#     }
#   ).call
#
class Emails::Confirmation < Notify::Email
end
