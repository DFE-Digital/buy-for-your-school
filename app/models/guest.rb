require "dry-struct"

class Guest < Dry::Struct
  def guest?
    true
  end

  def agent?
    false
  end

  # @return [nil]
  def id
    nil
  end

  # @return [Array] empty DSI org array
  def orgs
    []
  end

  def full_name; end

  def first_name; end

  def last_name; end

  def email; end
end
