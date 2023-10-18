module Email::Presentable
  extend ActiveSupport::Concern

  def sender_email
    sender["address"]
  end

  def sender_first_name
    sender_name_parts.first
  end

  def sender_last_name
    sender_name_parts.last
  end

private

  def sender_name_parts
    first_name, *rest = sender["name"].split(" ")
    [first_name, Array(rest).join(" ")]
  end
end
