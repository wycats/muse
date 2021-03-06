$:.push File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require "muse/preprocessor"
require "muse/listing_grabber"

class Spec::ExampleGroup
  def figure(name, number, text = nil)
    source = "<img src='/root/#{name}' />\n" \
             "<p class='figure title'><a name='1-#{name}'>Figure 1.#{number}</a>"
    source << " #{text}" if text
    source << "</p>"
  end

  def note(text)
    "<div class='note Note'><p class='note_head'>Note</p><p>#{text}</p></div>"
  end

  before(:each) do
    @muse = Muse::Preprocessor.new(:root => "/root", :chapter => 1)
  end
end