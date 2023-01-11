require_relative("response")

class Router
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

  # SECURITY ISSUE: command `curl localhost:2000/../server.rb --path-as-is`
  # would send the server.rb file back to the client.
  def render(path)
    full_path = File.join(__dir__, "views", path)
    not_found_page_path = File.join(__dir__, "views", "404.html")
    if File.exist?(full_path)
      Response.new(code: 200, body: File.binread(full_path))
    else
      Response.new(code: 404, body: File.binread(not_found_page_path))
    end
  end

  private

  attr_reader :request
end
