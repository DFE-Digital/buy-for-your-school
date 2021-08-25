require "dry-struct"

class Guest < Dry::Struct
  def guest?
    true
  end

  def admin?
    false
  end
end
