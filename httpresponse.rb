# frozen-string-literal: true

require_relative 'app'

MIME_TYPES = {
  'ai' => 'application/postscript',
  'asc' => 'text/plain',
  'avi' => 'video/x-msvideo',
  'avif' => 'image/avif',
  'bin' => 'application/octet-stream',
  'bmp' => 'image/bmp',
  'class' => 'application/octet-stream',
  'cer' => 'application/pkix-cert',
  'crl' => 'application/pkix-crl',
  'crt' => 'application/x-x509-ca-cert',
  'css' => 'text/css',
  'dms' => 'application/octet-stream',
  'doc' => 'application/msword',
  'dvi' => 'application/x-dvi',
  'eps' => 'application/postscript',
  'etx' => 'text/x-setext',
  'exe' => 'application/octet-stream',
  'gif' => 'image/gif',
  'htm' => 'text/html',
  'html' => 'text/html',
  'ico' => 'image/x-icon',
  'jpe' => 'image/jpeg',
  'jpeg' => 'image/jpeg',
  'jpg' => 'image/jpeg',
  'js' => 'application/javascript',
  'json' => 'application/json',
  'lha' => 'application/octet-stream',
  'lzh' => 'application/octet-stream',
  'mjs' => 'application/javascript',
  'mov' => 'video/quicktime',
  'mp4' => 'video/mp4',
  'mpe' => 'video/mpeg',
  'mpeg' => 'video/mpeg',
  'mpg' => 'video/mpeg',
  'otf' => 'font/otf',
  'pbm' => 'image/x-portable-bitmap',
  'pdf' => 'application/pdf',
  'pgm' => 'image/x-portable-graymap',
  'png' => 'image/png',
  'pnm' => 'image/x-portable-anymap',
  'ppm' => 'image/x-portable-pixmap',
  'ppt' => 'application/vnd.ms-powerpoint',
  'ps' => 'application/postscript',
  'qt' => 'video/quicktime',
  'ras' => 'image/x-cmu-raster',
  'rb' => 'text/plain',
  'rd' => 'text/plain',
  'rtf' => 'application/rtf',
  'sgm' => 'text/sgml',
  'sgml' => 'text/sgml',
  'svg' => 'image/svg+xml',
  'tif' => 'image/tiff',
  'tiff' => 'image/tiff',
  'ttc' => 'font/collection',
  'ttf' => 'font/ttf',
  'txt' => 'text/plain',
  'wasm' => 'application/wasm',
  'webm' => 'video/webm',
  'webmanifest' => 'application/manifest+json',
  'webp' => 'image/webp',
  'woff' => 'font/woff',
  'woff2' => 'font/woff2',
  'xbm' => 'image/x-xbitmap',
  'xhtml' => 'text/html',
  'xls' => 'application/vnd.ms-excel',
  'xml' => 'text/xml',
  'xpm' => 'image/x-xpixmap',
  'xwd' => 'image/x-xwindowdump',
  'zip' => 'application/zip'
}.freeze

# http response object
class HttpResponse
  attr_reader :http_code, :data, :headers, :file_path, :server_root, :is_static

  def initialize(httprequest, server_root)
    @server_root = server_root
    @headers = {}

    # TODO: validate path

    if httprequest.unsupported
      @http_code = 501
      @file_path = "#{@server_root}/501.html"
      @data = File.binread(@file_path)
      finish_response
      return
    end

    if httprequest.path.start_with?('/static/')
      @file_path = @server_root + httprequest.path
      @is_static = true
    else
      @file_path = @server_root + httprequest.path # add .rb extension?
    end

    if !File.exist?(@file_path) # will /form exist? or /form.rb
      @http_code = 404
      @file_path = "#{@server_root}/404.html"
      @data = File.binread(@file_path)
    else
      @http_code = 200
      prepare_response(httprequest)
    end

    finish_response
  end

  def send(client)
    client.write(@response)
  end

  private

  # TODO: handle dynamic files and endpoints

  # Prepares data part of response and sets content-type?
  def prepare_response(httprequest)
    if httprequest.method == 'GET'
      handle_get(httprequest)
    elsif httprequest.method == 'POST'
      handle_post(httprequest)
    end
  end

  def handle_get(httprequest)
    if is_static
      @data = File.binread(@file_path)
    else
      # render result
      params = httprequest.params
      @data = File.binread(@file_path)
    end
  end

  def handle_post(httprequest)
    # render result
    post_data = httprequest.post_data
    @data = File.binread(@file_path)
  end

  # Compiles all parts of response
  def finish_response
    # TODO: add Date, Encoding, Connection, Cookie headers

    headers['content-type'] = MIME_TYPES.fetch(@file_path.split('.')[-1])
    @response = "HTTP/1.1 #{@http_code}\r\n" \
                "Content-Type: #{headers['content-type']}\r\n" \
                "Content-Length: #{@data.size}\r\n" \
                "\r\n" \
                "#{@data}\r\n"
  end
end
