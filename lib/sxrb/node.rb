module SXRB
  class Node < Struct.new(:name, :attributes, :prefix, :uri, :namespaces, :parent)
    attr_accessor :children
    def initialize(*args, &block)
      super(*args, &block)
      @children = []
    end

    def append(node)
      node.parent = self
      @children << node
    end
  end
end
