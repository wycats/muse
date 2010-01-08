module Muse
  class InvalidReference < StandardError; end

  class Preprocessor
    attr_accessor :source

    def initialize(options = {})
      @options = options
      options.default = 0
    end

    def to_html
      tokens = Tokenizer.new(source).tokenize
      document = Parser.new(tokens).parse
      document.render(@options)
    end
  end

  class Parser
    class Document
      attr_accessor :ast, :tags, :refs

      def initialize
        @ast, @tags, @refs = [], Hash.new(0), []
      end

      def <<(node)
        node.document = self
        @ast << node
      end

      def render(options)
        result = ""
        ast.each do |node|
          result << node.to_html(options)
        end
        result
      end
    end

    def self.Node(*attrs)
      attrs << :document
      Struct.new(*attrs)
    end

    class StringNode < Node(:string)
      def to_html(options)
        string
      end
    end

    class RefNode < Node(:type, :name)
      def to_html(options)
        raise InvalidReference unless document.refs.include?(name)
        ""
      end
    end

    class TagNode < Node(:type, :number, :name, :body)
      def to_html(options)
        text = "#{type.capitalize} #{options[:chapter]}.#{number}"
        result = "<img src='#{options[:root]}/#{name}' />\n" \
        "<p class='#{type} title'><a name='#{options[:chapter]}-#{name}'>#{text}</a>"
        result << " #{body}" if body
        result << "</p>"
      end
    end

    def initialize(tokens)
      @document = Document.new
      @tokens = tokens.dup
    end

    def parse
      while token = @tokens.shift
        case token
        when Tokenizer::TkString
          @document << StringNode.new(token)
        when Tokenizer::TkTag
          if token.type == "ref"
            node = RefNode.new(token.name, token.body)
            @document << node
            @document.refs << node
          else
            number = (@document.tags[token] += 1)
            @document << TagNode.new(token.type, number, token.name, token.body)
          end
        end
      end
      @document
    end
  end

  class Tokenizer
    class TkString < String
    end

    class TkTag < Struct.new(:type, :name, :body)
    end

    def initialize(string)
      @string   = string.dup
      @tokens   = [TkString.new]
    end

    def tokenize
      while char = getchar
        if char == ?< && (match = special_tag)
          push_tag_token(match)
        else
          current_token << char
        end
      end
      @tokens
    end

    TAGS = "figure"

    def special_tag
      @string.match(/(#{TAGS}):([^>]+?)(?::"((?:[^"]|\\\")+)")?>/)
    end

    def push_tag_token(match)
      @string.slice!(0, match[0].size)
      @tokens << TkTag.new(match[1], match[2], match[3])
      @tokens << TkString.new
    end

    def current_token
      @tokens.last
    end

    def getchar
      @string.slice!(0)
    end
  end
end