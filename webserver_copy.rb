# frozen_string_literal: true

require 'socket'

SERVER_ROOT = '/home/errorxyz/Documents/ruby_proj/'

def parse_request(request)
  method, path, _version = request.lines[0].split(' ')

  { path: path, method: method, header: parse_headers(request) }
end

def parse_headers(request)
  headers = {}
  request.lines[1..].each do |line|
    if line == "\r\n"
      return headers
    end

    header, value = line.split(' ')
    header = header.gsub(':', ' ').downcase.to_sym
    headers[header] = value
  end
end

def prepare_response(request)
  if request.fetch(:path) == '/'
    respond_with("#{SERVER_ROOT}index.html")
  else
    respond_with(SERVER_ROOT + request.fetch(:path))
  end
end

def respond_with(path)
  if File.exist?(path)
    send_ok_response(File.binread(path))
  else
    send_file_not_found
  end
end

def send_ok_response(data)
  Response.new(code: 200, data: data)
end

def send_file_not_found
  Response.new(code: 404)
end

# Response object
class Response
  attr_reader :code

  def initialize(code:, data: '')
    @response = "HTTP/1.1 #{code}\r\n" \
                "Content-Length: #{data.size}\r\n" \
                "\r\n" \
                "#{data}\r\n"

    @code = code
  end

  def send(client)
    client.write(@response)
  end
end

server = TCPServer.new('localhost', 8080)
puts 'Server started on port 8080'

loop do
  client = server.accept
  request = client.readpartial(2048)

  request  = parse_request(request)
  response = prepare_response(request)

  puts "#{client.peeraddr[3]} #{request.fetch(:path)} - #{response.code}"
  response.send(client)
  client.close
end
