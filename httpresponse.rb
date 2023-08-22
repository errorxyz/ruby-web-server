# frozen-string-literal: true

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
  attr_reader :http_code, :data, :headers

  def initialize(httprequest, server_root)
    @server_root = server_root
    if httprequest.unsupported
      @http_code = 500
      @data = File.binread('500.html')
    elsif !File.exist?(@server_root + httprequest.path)
      @http_code = 404
      @data = File.binread('404.html')
      headers['content-type'] = 'text/html'
    elsif httprequest.method == 'GET'
      handle_get(httprequest)
    elsif httprequest.method == 'POST'
      handle_post(httprequest)
    end

    parse_response(httprequest)
  end

  def send(client)
    client.write(@response)
  end

  private

  # TODO: separately handle static and dynamic files and endpoints
  # parse response.data
  def handle_get(httprequest)
    @http_code = 200
    @data = File.binread(@server_root + httprequest.path)
  end

  # parse response.data
  def handle_post(httprequest)
    @http_code = 200
    @data = File.binread(@server_root + httprequest.path)
  end

  def parse_response(httprequest)
    @response = "HTTP/1.1 #{@http_code}\r\n" \
                "Content-Type: #{MIME_TYPES.fetch(httprequest.path.split('.')[-1])}\r\n" \
                "Content-Length: #{@data.size}\r\n" \
                "\r\n" \
                "#{@data}\r\n"
  end
end
