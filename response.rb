class Response
  def initialize(code:, body: "")
    @code = code
    @body = body
  end

  # can programmatically update content type depending on what body is being sent
  def send(client)
    client.print("HTTP/1.1 #{code}\r\n")
    client.print("Content-Type: text/html\r\n")
    client.print("\r\n")
    client.print("#{body}\r\n") unless body.nil?

    puts "-> #{code}"
    client.close
  end

  attr_reader :code, :body
end
