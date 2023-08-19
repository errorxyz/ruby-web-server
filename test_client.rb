require 'socket'
require_relative 'httprequest'
require_relative 'httpresponse'

server = TCPServer.new('127.0.0.1', 8888)
puts 'Listening on port 8888...'

loop do
  client = server.accept
  request = client.readpartial 2048

  request = HttpRequest.new(request)
  response = HttpResponse.new(request, '/home/errorxyz/Documents/ruby_proj')

  puts "#{client.peeraddr[3]} #{request.path} - #{response.http_code}"
  response.send(client)
  client.close
end
