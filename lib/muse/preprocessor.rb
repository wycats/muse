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
    module Nodes
      class Node < Struct.new(:document, :children)
        def initialize document = nil, children = []
          super
        end

        def << node
          node.document = document
          self.children << node
        end
      end

      class Document < Node
        attr_accessor :tags, :refs

        def initialize
          super
          self.document = self
          @tags, @refs = Hash.new(0), []
        end

        def render(options)
          children.map { |node| node.to_html(options) }.join
        end
      end

      class String < Node
        def initialize string
          super()
          @string = string
        end

        def to_html opts = {}
          @string
        end
      end

      class Ref < Node
        attr_reader :name, :body
        def initialize name, body
          super()
          @name = name
          @body = body
        end

        def to_html(options)
          raise InvalidReference unless document.refs.include?(name)
          ""
        end
      end

      class Tag < Ref
        attr_reader :number, :token_type
        def initialize name, body, number, token_type
          super(name, body)
          @number     = number
          @token_type = token_type
        end

        def to_html(options)
          text = "#{token_type.capitalize} #{options[:chapter]}.#{number}"
          result = "<img src='#{options[:root]}/#{name}' />\n" \
          "<p class='#{token_type} title'><a name='#{options[:chapter]}-#{name}'>#{text}</a>"
          result << " #{body}" if body
          result << "</p>"
        end
      end
    end

    def initialize(tokens)
      @document = Nodes::Document.new
      @tokens = tokens.dup
    end

    def parse
      while token = @tokens.shift
        case token
        when Tokenizer::TkString
          @document << Nodes::String.new(token)
        when Tokenizer::TkTag
          if token.type == "ref"
            node = Nodes::Ref.new(token.name, token.body)
            @document << node
            @document.refs << node
          else
            number = (@document.tags[token] += 1)
            @document << Nodes::Tag.new(token.name, token.body, number, token.type)
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
