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

  require 'strscan'

  class Tokenizer
    class TkString < String
    end

    class TkTag < Struct.new(:type, :name, :body)
    end

    def initialize(string)
      @scanner  = StringScanner.new(string.dup)
      @tokens   = []
    end

    TAGS = "figure"

    def tokenize
      tag = /<(#{TAGS}):[^:>]*(:[^>]*)?>/
      tks = TkString.new

      until @scanner.eos? do
        case
        when text = @scanner.scan(tag)
          @tokens << tks
          type, name, body = *text.gsub(/(^<|>$)/, '').split(':', 3)
          body.gsub!(/(^['"]|['"]$)/, '') if body

          @tokens << TkTag.new(type, name, body)
          tks = TkString.new
          next
        when text = @scanner.scan(/./)
          tks << text
          next
        end
      end

      @tokens << tks unless tks.empty?

      @tokens
    end
  end
end
