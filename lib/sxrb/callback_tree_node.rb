module SXRB
  class CallbackTreeNode
    attr_reader :children, :parent
    attr_writer :on_whole_element

    def initialize(options = {})
      @parent = options[:parent]
      @children = Hash.new {|h,k| h[k] = CallbackTreeNode.new(:parent => self)}
    end

    def add(tag)
      Proxy.new(@children[tag])
    end

    def on_whole_element(node)
      @on_whole_element.call(node) if @on_whole_element
    end
  end
end
