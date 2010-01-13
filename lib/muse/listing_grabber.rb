module Muse
  class ListingGrabber
    def initialize(glob)
      Dir[glob].each do |file|
        require file
      end
    end

    def grab(identifier)
      klass, method = identifier.split(/#/)
      const = klass.split("::").inject(Object) {|const, part| const.const_get(part) }
      file, line = const.instance_method(method).source_location

      code = []
      index = line - 1
      @text = File.read(file).split("\n")
      @start_margin = margin(@text[index])

      code << get_line(index)

      loop do
        index += 1
        code << get_line(index)
        next if @text[index] =~ /^\s*(rescue|ensure)/
        break if !@text[index] || margin(@text[index]) == @start_margin
      end
      
      code.join("\n")
    end

    def get_line(index)
      @text[index][@start_margin..-1]
    end

    def margin(line)
      return 0 if line =~ /^\s*$/
      line.match(/^\s*/)[0].size
    end
  end
end