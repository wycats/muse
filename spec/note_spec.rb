describe Muse::Preprocessor do
  describe "processes notes" do
    it "replaces single-line notes with a note div" do
      @muse.source = "<note>Hello</note>"
      @muse.to_html.should == note("Hello")
    end

    it "replaces multi-line notes with a note div" do
      @muse.source = "<note>\nHello\n</note>"
      @muse.to_html.should == note("\nHello\n")
    end

    it "allows references in notes" do
      @muse.source = "<figure:hello.png><note>As shown in <ref:figure:hello.png></note>"
      @muse.to_html.should == figure("hello.png", 1) << note("As shown in Figure 1.1")
    end

    it "complains if a tag is incorrectly closed" do
      @muse.source = "<note>Hello</figure>"
      lambda { @muse.to_html }.should raise_error(Muse::MismatchedTag)
    end

    it "includes the line number in the exception" do
      @muse.source = "hello\n<note>Hello</figure>\nomg"
      begin
        @muse.to_html
      rescue Muse::MismatchedTag => e
        e.line.should == 2
      end
    end

  end
end