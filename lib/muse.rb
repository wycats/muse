require "muse/preprocessor"
require "maruku"

module Muse
  VERSION = "0.5.0"

  def initialize(string, css = "")
    @string, @css = Maruku.new(string).to_html, css
  end

  def self.to_pdf
    require "flying_saucer/rufo"
    ITextRenderer.new.make_pdf(@string)
  end
end
