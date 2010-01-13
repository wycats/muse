describe Muse::ListingGrabber do
  before do
    file = File.expand_path("#{File.dirname(__FILE__)}/fixtures/contents.rb")
    @grabber = Muse::ListingGrabber.new(file)
  end

  it "can get simple listings" do
    @grabber.grab("Fixtures::Contents#hello").should == "def hello\n\nend"
  end

  it "can get listings where the method has content" do
    @grabber.grab("Fixtures::Contents#hello2").should == "def hello2\n  puts \"Hello\"\nend"
  end

  it "can get listings with more complex bodies" do
    @grabber.grab("Fixtures::Contents#hello3").should == <<-METHOD.gsub(/^      /, '').chomp
      def hello3
        if name == :yehuda
          puts "Hello"
        else
          raise "OMG"
        end
      end
    METHOD
  end
  
  it "can get listings with blocks" do
    @grabber.grab("Fixtures::Contents#hello4").should == <<-METHOD.gsub(/^      /, '').chomp
      def hello4
        names.each do |name|
          say "HELLO!"
        end
      end
    METHOD
  end
  
  it "can get listings with rescue and ensure at the front" do
    @grabber.grab("Fixtures::Contents#hello5").should == <<-METHOD.gsub(/^      /, '').chomp
      def hello5
        puts "HELLO!"
      rescue
        puts "OMG"
      ensure
        puts "OMGOMG"
      end
    METHOD
  end
end