class CookiePolicy
  def initialize(cookies)
    @cookies = cookies
  end

  def set?
    response.in?(%w[accepted rejected])
  end

  def accepted?
    response == "accepted"
  end

  def rejected?
    response == "rejected"
  end

  def response=(response)
    @cookies[:cookie_policy] = { value: response, expires: 1.year.from_now }
    response
  end

  def response
    @cookies[:cookie_policy]
  end
end
