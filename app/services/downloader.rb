require "dry-initializer"
require "types"

# GET a url
#
class Downloader
  class DownloadError < StandardError; end
  extend Dry::Initializer

  # @!attribute encoding
  # @!visibility private
  # @return [String] (defaults to UTF-8)
  option :encoding,  reader: false, default: proc { "UTF-8" }
  # @!attribute redirects
  # @!visibility private
  # @return [Integer] (defaults to 5)
  option :redirects, reader: false, default: proc { 5 }, type: Types::Integer

  # @param url [String]
  #
  # @return [Tempfile]
  #
  def call(url)
    response = client.get(url, follow_redirect: true)

    if response.ok?
      temp_file(response)
    else
      raise DownloadError, "#{response.status} response for #{url}"
    end
  end

private

  # @param response []
  #
  # @return [Tempfile]
  #
  def temp_file(response)
    body = response.body.force_encoding(@encoding)
    file = Tempfile.new(encoding: @encoding)
    file.write(body)
    file.close
    file
  end

  # Improved memory usage in downloading large files vs Net/HTTP
  #
  # @return [HTTPClient]
  #
  def client
    return @client if @client

    @client = HTTPClient.new
    @client.follow_redirect_count = @redirects
    @client
  end
end
