# frozen-string-literal: true

# http response object
class HttpResponse
  attr_reader :http_code, :data

  def initialize(httprequest, server_root)
    @server_root = server_root
    if httprequest.unsupported
      @http_code = 500
      @data = File.binread('500.html')
    elsif !File.exist?(@server_root + httprequest.path)
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

  # TODO - separately handle static and dynamic files and endpoints
  # parse response.data
  def handle_get(httprequest)
    @data = File.binread(@server_root + httprequest.path)
  end

  # parse response.data
  def handle_post(httprequest)
    @data = File.binread(@server_root + httprequest.path)
  end

  def parse_response
    @response = "HTTP/1.1 #{@http_code}\r\n" \
                "Content-Length: #{@data.size}\r\n" \
                "\r\n" \
                "#{@data}\r\n"
  end
end
