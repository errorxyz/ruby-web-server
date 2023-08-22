# frozen-string-literal: true

require 'socket'
require_relative 'httprequest'
require_relative 'httpresponse'

# subdomains point to website_root
hosts = { 'test.localhost' => '/home/errorxyz/Documents/ruby_proj',
          'website.localhost' => '/home/errorxyz/Documents/errorxyz.github.io',
          'localhost' => '/home/errorxyz/Documents/ruby_proj' }

server = TCPServer.new('0.0.0.0', 8888)
puts 'Listening on port 8888...'

loop do
  client = server.accept
  request = client.readpartial 2048

  request = HttpRequest.new(request)

  host = request.headers.fetch(:host).split(':')[0]
  website_root = hosts[host]
  website_root = hosts['localhost'] if website_root.nil?

  response = HttpResponse.new(request, website_root)

  puts "#{client.peeraddr[3]} #{request.method} #{host}#{request.path} - #{response.http_code}"
  response.send(client)
  client.close
end
