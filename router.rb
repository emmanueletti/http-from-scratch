require "rack"
require "rackup/lobster" # sample rack application
require_relative("response")

class Router
  APP = Rackup::Lobster.new

  def initialize(request)
    @request = request
  end

  def route
    case @request.path
    when "/"
      render("index.html")
    else
      render(request.path)
    end
  end

  private

  # SECURITY ISSUE: command `curl localhost:2000/../server.rb --path-as-is`
  # would send the server.rb file back to the client.
  def render(path)
    full_path = File.join(__dir__, "views", path)

    # Same pattern as web servers like nginx, they will first try to see if they
    # have the request file/resource on disk - like files/assets in the public folder
    # if not then they send the request over to the rack application
    if File.exist?(full_path)
      headers = {"Content-Type": "text/html\r\n"}
      Response.new(status: 200, headers: headers, body: [File.binread(full_path)])
    else
      send_to_rack_application
    end
  end

  def send_to_rack_application
    status, headers, body = APP.call({
      REQUEST_METHOD: request.method,
      PATH_INFO: request.path,
      QUERY_STRING: request.query
    })

    Response.new(status:, headers:, body:)
  rescue => e
    puts e.full_message
    # Protection from whatever might crach within the rack application
    Response.new(status: "504", headers:, body: ["Something went wrong"])
  end

  attr_reader :request
end
