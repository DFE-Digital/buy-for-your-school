class Rack::Attack
  BOT_PATH_PATTERNS = %w[
    wp-admin
    wp-login
    login
    hangfire
    dbconsole
    WebInterface
    Synchronization
    asispanel
    sslmgr
    listinfo
    dfshealth
    xmlrpc
    goform
    jsinvoke
    etc/passwd
  ].freeze

  FILE_EXTENSIONS = %w[
    php
    aspx
    md
    htm
    html
    asp
    jsp
    cgi
    pl
    py
    rb
    bak
    old
    tmp
    log
    env
    ini
    config
    sql
    db
    xml
    yaml
    txt
    doc
    docx
    xls
    xlsx
    pdf
    exe
    dll
    bat
    sh
    git
    svn
  ].freeze

  EXPLOIT_PATTERNS = %w[ldap: exec cmd oast.me .. GeneralDocs CHANGELOG].freeze

  def self.suspicious_request?(req)
    req.path.start_with?("/~") ||
      BOT_PATH_PATTERNS.any? { |pattern| req.path.include?(pattern) } ||
      FILE_EXTENSIONS.any? { |ext| req.path =~ /\.#{ext}($|\?)/ } ||
      EXPLOIT_PATTERNS.any? { |pattern| req.path.include?(pattern) } ||
      (%w[TRACE OPTIONS].include?(req.request_method) && req.path == "/")
  end

  throttle("req/ip", limit: 100, period: 2.minutes, &:ip)

  blocklist("block suspicious requests") do |req|
    suspicious_request?(req)
  end
end
