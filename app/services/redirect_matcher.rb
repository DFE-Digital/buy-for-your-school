class RedirectMatcher
  CACHE_KEY = "contentful/redirects".freeze
  CACHE_EXPIRY = 1.day

  Result = Data.define(:redirect, :destination_path, :status)

  def self.call(path, redirects: cached_redirects)
    new(path, redirects:).call
  end

  def self.cached_redirects
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) do
      Redirect.all
    end
  end

  def initialize(path, redirects: self.class.cached_redirects)
    @path = path
    @redirects = redirects
  end

  def call
    redirect = redirects.find { |rule| matches?(rule) }
    return nil unless redirect

    Result.new(
      redirect:,
      destination_path: resolve_destination_path(redirect),
      status: redirect.permanent? ? :moved_permanently : :found,
    )
  end

private

  attr_reader :path, :redirects

  def matches?(redirect)
    if wildcard_rule?(redirect.source_path)
      wildcard_match?(redirect.source_path)
    else
      redirect.source_path == path
    end
  end

  def resolve_destination_path(redirect)
    return redirect.destination_path unless wildcard_rule?(redirect.source_path)

    wildcard_destination(redirect.destination_path, wildcard_remainder(redirect.source_path))
  end

  def wildcard_rule?(pattern)
    pattern.end_with?("/*")
  end

  def wildcard_match?(source_path)
    prefix = wildcard_prefix(source_path)
    path == prefix || path.start_with?("#{prefix}/")
  end

  def wildcard_remainder(source_path)
    prefix = wildcard_prefix(source_path)
    return "" if path == prefix

    path.delete_prefix("#{prefix}/")
  end

  def wildcard_destination(destination_path, remainder)
    return destination_path unless wildcard_rule?(destination_path)

    destination_prefix = wildcard_prefix(destination_path)
    remainder.present? ? "#{destination_prefix}/#{remainder}" : destination_prefix
  end

  def wildcard_prefix(pattern)
    pattern.delete_suffix("/*")
  end
end
