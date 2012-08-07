module SXRB
  # Node class is simple DOM-like element, which allows easy travesing through
  # restricted part of document structure with #children and #parent methods.
  class Node < Struct.new(:name, :attributes, :prefix, :uri, :namespaces, :parent)
    attr_accessor :children
    # Internal method used to build DOM-like structure.
    # @api private
    def initialize(*args, &block)
      super(*args, &block)
      @children = []
    end

    # Internal method used to build DOM-like structure.
    # @api private
    def append(node)
      node.parent = self
      @children << node
    end


    # Returns text content of a node (recursively), skipping all markup.
    # @return [String]
    #   Text content of this node and all it's descendants is returned,
    #   concatenated.
    def content
      children.map {|child| child.is_a?(TextNode)? child.text : child.content}.flatten.join('')
    end
  end
end
