class Response
  def initialize(status:, headers: {}, body: "")
    @status = status
    @headers = headers
    @body = body.join
  end

  # can programmatically update content type depending on what body is being
  # sent

  def send(client)
    client.print("HTTP/1.1 #{status}\r\n")
    print_headers(client)
    client.print("\r\n")
    client.print("#{body}\r\n") unless body.nil?

    puts "-> #{status}"
    client.close
  end

  attr_reader :status, :headers, :body

  private

  def print_headers(client)
    headers.each do |name, value|
      client.print("#{name}: #{value}\r\n")
    end
  end
end
