# frozen_string_literal: true

# Main controller
class MainController
  def initialize(request)
    @request = request
    @basic_template = path_to('main_template.html.erb')
    @user = User.current(request)
  end

  def render_layout(layout)
    [path_to(layout), @basic_template].inject(nil) do |first, second|
      render(second) { first }
    end
  end

  def render(path)
    ERB.new(File.read(path)).result(binding)
  end

  def build_responce
    raise 'Not implemented method!'
  end

  def path_to(template)
    File.expand_path("../public/views/#{template}", __FILE__)
  end
end
