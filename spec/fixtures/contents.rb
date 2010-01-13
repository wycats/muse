module Fixtures
  class Contents
    def hello

    end
    
    def hello2
      puts "Hello"
    end
    
    def hello3
      if name == :yehuda
        puts "Hello"
      else
        raise "OMG"
      end
    end

    def hello4
      names.each do |name|
        say "HELLO!"
      end
    end
    
    def hello5
      puts "HELLO!"
    rescue
      puts "OMG"
    ensure
      puts "OMGOMG"
    end
  end
end