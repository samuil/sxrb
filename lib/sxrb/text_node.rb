module SXRB
  # Class representing special case of DOM nodes which contain only text, and
  # don't represent any particular element.
  class TextNode < Node
    # @api private
    def initialize(text)
      @text = text || ""
    end

    # @api private
    def append_text(text)
      @text << text
    end

    # Accessor for text data kept in TextNode object.
    # @return [String]
    attr_reader :text
  end
end
