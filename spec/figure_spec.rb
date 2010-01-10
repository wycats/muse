describe Muse::Preprocessor do
  processor = Muse::Preprocessor

  describe "figure" do
    before do
      @muse = processor.new(:root => "/root", :chapter => 1)
    end

    def figure(name, number, text = nil)
      source = "<img src='/root/#{name}' />\n" \
               "<p class='figure title'><a name='1-#{name}'>Figure 1.#{number}</a>"
      source << " #{text}" if text
      source << "</p>"
    end

    it "coverts <figure:foo.png> into an img tag" do
      @muse.source = "<figure:foo.png>"
      @muse.to_html.should == figure("foo.png", 1)
    end

    it "converts 'foo <figure:foo.png> foo' correctly" do
      @muse.source = "foo <figure:foo.png> foo"
      @muse.to_html.should == "foo #{figure('foo.png', 1)} foo"
    end

    it "converts <figure:foo.png:Additional Text> correctly" do
      @muse.source = "<figure:foo.png:\"Additional Text\">"
      @muse.to_html.should == figure("foo.png", 1, "Additional Text")
    end

    it "converts 'foo <figure:foo.png:Additional Text> foo' correctly" do
      @muse.source = "foo <figure:foo.png:\"Additional Text\"> foo"
      html = figure("foo.png", 1, "Additional Text")
      @muse.to_html.should == "foo #{html} foo"
    end

    it "converts multiple figures using ascending numbers" do
      @muse.source = "<figure:foo.png><figure:bar.png>"
      @muse.to_html.should == figure("foo.png", 1) + figure("bar.png", 2)
    end

    it "raises an exception if a figure reference doesn't exist" do
      lambda { @muse.source = "<ref:figure:foo.png>"; @muse.to_html }.
        should raise_error(Muse::InvalidReference)
    end

    it "fills in the reference correctly if the reference comes after" do
      @muse.source = "<figure:foo.png><ref:figure:foo.png>"
      @muse.to_html.should == "#{figure('foo.png', 1)}Figure 1.1"
    end

    it "fills int he reference correctly if the reference comes first" do
      @muse.source = "<ref:figure:foo.png><figure:foo.png>"
      @muse.to_html.should == "Figure 1.1#{figure('foo.png', 1)}"
    end
  end
end