require "dry-struct"

class Guest < Dry::Struct
  def guest?
    true
  end

  def agent?
    false
  end

  def internal?
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

  # @return [nil]
  def full_name
    nil
  end

  # @return [nil]
  def first_name
    nil
  end

  # @return [nil]
  def last_name
    nil
  end

  # @return [nil]
  def email
    nil
  end
end
