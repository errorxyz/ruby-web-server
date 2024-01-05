# frozen-string-literal: true

require 'socket'
require_relative 'httprequest'
require_relative 'httpresponse'

# Http Server class
class HttpServer
  def initialize(ip, port, hosts, blacklist = [])
    @hosts = hosts
    @port = port.to_i
    @ip = ip
    @blacklist = blacklist
  end

  def start
    server = TCPServer.new(@ip, @port)
    puts 'Listening on port 8888...'

    loop do
      client = server.accept
      request = client.readpartial 2048

      if client.peeraddr[3] in @blacklist
        response = "HTTP/1.1 401 Unauthorized\r\n"
        client.write(response)
        next
      end

      request = HttpRequest.new(request)

      host = request.headers.fetch(:host).split(':')[0]
      website_root = hosts[host]
      website_root = hosts['localhost'] if website_root.nil?

      response = HttpResponse.new(request, website_root)

      puts "#{client.peeraddr[3]} #{request.method} #{host}#{request.path} - #{response.http_code}"
      response.send(client)
      client.close
    end
  end
