require "java"
require "stringio"

require "flying_saucer/jars/itext"
require "flying_saucer/jars/core-renderer"
import org.xhtmlrenderer.pdf.ITextRenderer

java.lang.System.set_property("java.awt.headless", "true")

class ITextRenderer
  def make_pdf(input)
    io = StringIO.new
    set_document_from_string input
    layout
    create_pdf(io.to_outputstream)
    io.string
  end
end
