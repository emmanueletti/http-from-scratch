class Request
  def initialize(http_text)
    http_text_lines = http_text.lines
    @method, @path, _http_version = http_text_lines.first.split
    @path, @query = @path.split("?")

    # Logging
    puts "-> #{http_text_lines.first.chomp}"

    index = http_text_lines.index("\r\n")
    raw_headers = http_text_lines[1...index]
    @headers = parse_headers(raw_headers)

    @body = http_text_lines[(index + 1)..].join
  end

  def content_length
    headers["content-length"].to_i
  end

  attr_reader :headers, :body, :path, :query

  private

  def parse_headers(raw_headers)
    result = {}
    raw_headers.map do |header|
      name, value = header.chomp.split(": ")
      result[name.downcase] = value.downcase
    end
    result
  end
end
