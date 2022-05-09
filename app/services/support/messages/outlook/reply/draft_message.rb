module Support
  module Messages
    module Outlook
      module Reply
        class DraftMessage < SimpleDelegator
          def inbox?
            false
          end

          def merged_body_content(reply_text)
            # reply_text    # - for a more concise reply, although from reply 3 it gets messy again
            "<html><body>#{reply_text}</body></html>#{body.content}"
          end

          def sender
            { address: from.email_address.address, name: from.email_address.name }
          end

          def recipients
            to_recipients.map(&:email_address).map do |email_address|
              { address: email_address.address, name: email_address.name }
            end
          end

          def case_reference_from_headers
            found_header = internet_message_headers.find { |header| header["name"] == "x-GHBS-CaseReference" }
            found_header.present? ? found_header["value"] : nil
          end

          def replying_to_email_from_headers
            found_header = internet_message_headers.find { |header| header["name"] == "x-ReplyingToSupportEmail" }
            found_header.present? ? found_header["value"] : nil
          end
        end
      end
    end
  end
end
