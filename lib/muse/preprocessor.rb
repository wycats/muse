module Muse
  class ParseError < StandardError
    attr_accessor :line
    def initialize(line, str)
      super(str)
      @line = line
    end
  end
  class InvalidReference < ParseError; end
  class MismatchedTag < ParseError; end

  class Preprocessor
    attr_accessor :source

    def initialize(options = {})
      @options = options
      options.default = 0
    end

    def to_html
      tokens = Tokenizer.new(source).tokenize
      document = Parser.new(tokens).parse
      document.to_html(@options)
    end
  end

  class Parser
    module Nodes
      class Node < Struct.new(:document, :children, :line)
        def self.humanize
          name.split("::").last
        end

        def self.autoclose?
          false
        end

        def initialize(document = nil, children = [])
          super
        end

        def number
          document.tags[self.class].index(self) + 1
        end

        def <<(node)
          node.document = document

          # Cache the node so it can be easily referenced
          document.tags[node.class] << node
          self.children << node
        end

        def render_children(options)
          children.map { |node| node.to_html(options) }.join
        end
      end

      class Document < Node
        attr_accessor :tags, :refs

        def initialize
          super
          self.document = self
          @tags, @refs = Hash.new {|h,k| h[k] = [] }, []
        end

        alias to_html render_children
      end

      class String < Node
        def initialize(string, line)
          super()
          @string   = string
          self.line = line
        end

        def to_html opts = {}
          @string
        end
      end

      class Ref < Node
        def self.autoclose?
          true
        end

        attr_reader :node_type, :body
        def initialize(node_type, body, line)
          super()
          @node_type = node_type
          @body      = body
          self.line  = line
        end

        def associated_tag
          @tag ||= document.tags[node_type].find {|t| t.name == body }
        end

        def to_html(options)
          unless associated_tag
            raise InvalidReference.new(line, "You referenced #{body} on line #{line} " \
                                             "but didn't define it anywhere.")
          end

          "#{node_type.humanize} #{options[:chapter]}.#{associated_tag.number}"
        end
      end

      class Tag < Node
        attr_reader :name, :body
        def initialize(name, body, line)
          super()
          @name       = name
          @body       = body
          self.line   = line
        end

        def ==(other)
          self.class == other.class && name == other.name && body == other.body
        end
      end

      class Figure < Tag
        def self.autoclose?
          true
        end

        def to_html(options)
          text = "Figure #{options[:chapter]}.#{number}"
          result = "<img src='#{options[:root]}/#{name}' />\n" \
          "<p class='figure title'><a name='#{options[:chapter]}-#{name}'>#{text}</a>"
          result << " #{body}" if body
          result << "</p>"
        end
      end

      class Note < Tag
        def to_html(options)
          contents = render_children(options)
          "<div class='note Note'><p class='note_head'>Note</p><p>#{contents}</p></div>"
        end
      end
    end

    def initialize(tokens)
      @document = Nodes::Document.new
      @tokens = tokens.dup
      @stack = [@document]
    end

    def parse
      while token = @tokens.shift
        case token
        when Tokenizer::TkString
          @stack.last << Nodes::String.new(token, token.line)
        when Tokenizer::TkTag
          node = token.type.new(token.name, token.body, token.line)
          @stack.last << node
          @stack << node
        when Tokenizer::TkEndTag
          tag = @stack.pop
          unless tag.class == token.type
            raise MismatchedTag.new(tag.line, "You opened a #{tag.class.humanize} " \
              "on #{tag.line} and closed with a #{token.type.humanize} on #{token.line}")
          end
        end
      end

      @document
    end
  end

  require 'strscan'

  class Tokenizer
    class TkString < String
      attr_reader :line
      def initialize(line)
        @line = line
        super()
      end
    end

    class TkTag < Struct.new(:type, :name, :body, :line)
    end

    class TkEndTag < Struct.new(:type, :line)
    end

    def initialize(string)
      @scanner  = StringScanner.new(string.dup)
      @tokens   = []
      @line     = 1
    end

    TAGS  = "ref|figure|note"
    AUTOCLOSE = %r{ref|figure}
    TYPES = {"figure" => Parser::Nodes::Figure,
             "ref" => Parser::Nodes::Ref,
             "note" => Parser::Nodes::Note }

    def tokenize
      tag   = %r{<(#{TAGS})(:[^:>]*)?(:[^>]*)?>}
      close = %r{</(#{TAGS})>}
      tks   = TkString.new(@line)

      until @scanner.eos? do
        if text = @scanner.scan(tag)
          @tokens << tks unless tks.empty?
          type, name, body = *text.gsub(/(^<|>$)/, '').split(':', 3)
          body.gsub!(/(^['"]|['"]$)/, '') if body

          name = TYPES[name] if type == "ref"
          type = TYPES[type]
          @tokens << TkTag.new(type, name, body, @line)
          @tokens << TkEndTag.new(type, @line) if type.autoclose?
          tks = TkString.new(@line)
        elsif text = @scanner.scan(close)
          @tokens << tks unless tks.empty?
          @tokens << TkEndTag.new(TYPES[close.match(text)[1]], @line)
          tks = TkString.new(@line)
        elsif text = @scanner.get_byte
          @line += 1 if text == "\n"
          tks << text
        end
      end

      @tokens << tks unless tks.empty?

      @tokens
    end
  end
end
