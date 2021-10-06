require "dry-struct"

class Guest < Dry::Struct
  def guest?
    true
  end

  def agent?
    false
  end
end
