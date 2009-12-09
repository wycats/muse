require "flying_saucer/rufo"
require "maruku"

class Muse
  def initialize(string, css = "")
    @string, @css = Maruku.new(string).to_html, css
  end

  def to_pdf
    ITextRenderer.new.make_pdf(@string)
  end
end
