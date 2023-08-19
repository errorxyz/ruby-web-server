# frozen-string-literal: true

# http request object
class HttpRequest
  attr_reader :version, :path, :params, :method, :headers, :post_data, :unsupported

  def initialize(raw_request)
    @method, @path, @version = raw_request.lines[0].split
    @headers = parse_headers(raw_request)

    if @method == 'GET'
      parse_get
    elsif @method == 'POST'
      parse_post(raw_request)
    end
  end

  private

  def parse_headers(raw_request)
    headers = {}
    raw_request.lines[1..].each do |line|
      return headers if line == "\r\n"

      header, value = line.split(' ')
      header = header.gsub(':', '').downcase.to_sym
      headers[header] = value
    end
  end

  def parse_get
    @path, params = @path.split('?')
    @path = '/index.html' if @path == '/'

    @params = {}

    params&.split('&')&.each do |param|
      key, val = param.split('=')
      key = key.to_sym
      @params[key] = val
    end
  end

  def parse_post(raw_request)
    @path = '/index.html' if @path == '/'

    if headers[:"content-type"] == 'application/x-www-form-urlencoded'
      parse_form(raw_request)
    elsif headers[:"content-type"] == 'multipart/form-data'
      # cant handle for now
      @post_data = request.lines[headers.length..]

    else
      # return 500 error - server side error
      @unsupported = true
    end
  end

  def parse_form(raw_request)
    @post_data = {}
    params = raw_request.lines[-1]

    params&.split('&')&.each do |param|
      key, val = param.split('=')
      key = key.to_sym
      @post_data[key] = val
    end
  end
end
