describe Muse::Preprocessor do
  processor = Muse::Preprocessor

  describe "figure" do
    before do
      @muse = processor.new(:root => "/root", :chapter => 1)
    end

    it "coverts <figure:foo.png> into an img tag" do
      @muse.source = "<figure:foo.png>"
      @muse.to_html.should == "<img src='/root/foo.png' />\n" \
                              "<p class='figure title'><a name='1-foo.png'>Figure 1.1</a></p>"
    end

    it "converts 'foo <figure:foo.png> foo' correctly" do
      @muse.source = "foo <figure:foo.png> foo"
      @muse.to_html.should == "foo <img src='/root/foo.png' />\n" \
                              "<p class='figure title'><a name='1-foo.png'>Figure 1.1</a></p> foo"
    end

    it "converts <figure:foo.png:Additional Text> correctly" do
      @muse.source = "<figure:foo.png:\"Additional Text\">"
      @muse.to_html.should == "<img src='/root/foo.png' />\n" \
                              "<p class='figure title'><a name='1-foo.png'>Figure 1.1" \
                              "</a> Additional Text</p>"
    end

    it "converts 'foo <figure:foo.png:Additional Text> foo' correctly" do
      @muse.source = "foo <figure:foo.png:\"Additional Text\"> foo"
      @muse.to_html.should == "foo <img src='/root/foo.png' />\n" \
                              "<p class='figure title'><a name='1-foo.png'>Figure 1.1" \
                              "</a> Additional Text</p> foo"
    end

    it "raises an exception if a figure reference doesn't exist" do
      pending
      lambda { @muse.source = "<ref:figure:foo.png>" }.
        should raise_error(Muse::InvalidReference)
    end
  end
end