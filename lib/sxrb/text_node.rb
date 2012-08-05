module SXRB
  class TextNode < Node
    def initialize(text)
      @text = text || ""
    end

    def append_text(text)
      @text << text
    end

    def text
      @text
    end
  end
end
