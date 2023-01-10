require "socket" # ruby built in library for creating TCP servers
require_relative("request")
require_relative("router")

# https://gorails.com/episodes/ruby-http-server-from-scratch

# create a configurable port
# can be configured via the shell environment variable which can be
# set outside of the program
port = ENV.fetch("PORT", 2000).to_i
server = TCPServer.new(port)

puts "listening on port #{port}"

loop do
  # each time a client connects to the server, we spawn a new thread to handle
  # that connection. this way multiple connectons can be handled without wiating
  # for other connections to process. with no limit on how many threads to
  # create, this is limited by the machines capacity
  Thread.start(server.accept) do |client|
    # receive max of 2048 bytes of data from client
    raw_http_data = client.readpartial(2048)

    # pattern of an HTTP text message is lines broken up by new line seperator \n
    # [0] first line = method + path + http protocol (space seperated)
    # [1..x] second line to x number of lines = core headers + optional according to standards
    # [x...x] custom headers that start with X-HEADER-NAME (not 100% sure about this)
    # an empty line \r\n
    # then text bytes that refer to the body in a POST request

    # knowing this standard pattern, we can then programmatically process it and take action on whatever intruction / resource is being communicated over in bytes
    # For example:
    # is there a index.html on the file system
    # is there a "route" that responds to the request
    # is there an executbale to run
    # is there db actions to make
    # etc.
    # this is what Puma does with Rails
    # it takes the request and hands it over to the rack application (our app) that Rails runs (in config.ru)
    request = Request.new(raw_http_data)
    # p request.inspect
    # p request.content_length

    result = Router.new(request)

    # sending a message back
    client.print("HTTP/1.1 20 OK")
    client.print("Content-Type: text/html\r\n")
    client.print("\r\n")
    client.print("Body content text, the time is #{Time.now}\r\n")
    client.close
  end
end
