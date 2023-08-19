# frozen-string-literal: true

# http response object
class HttpResponse
  attr_reader :http_code, :data

  SERVER_ROOT = '/home/errorxyz/Documents/ruby_proj/'

  def initialize(httprequest)
    if httprequest.unsupported
      @http_code = 500
      @data = File.binread('500.html')
    elsif !File.exist?(SERVER_ROOT + httprequest.path)
      @http_code = 404
      @data = File.binread('404.html')
    elsif httprequest.method == 'GET'
      handle_get(httprequest)
    elsif httprequest.method == 'POST'
      handle_post(httprequest)
    end
  end

  def send(client)
    parse_response
    client.write(@response)
  end

  private

  # TODO - separately handle static and dynamic files
  # parse response.data
  def handle_get(httprequest)
    @data = File.binread(SERVER_ROOT + httprequest.path)
  end

  # parse response.data
  def handle_post(httprequest)
    @data = File.binread(SERVER_ROOT + httprequest.path)
  end

  def parse_response
    @response = "HTTP/1.1 #{@http_code}\r\n" \
                "Content-Length: #{@data.size}\r\n" \
                "\r\n" \
                "#{@data}\r\n"
  end
end
