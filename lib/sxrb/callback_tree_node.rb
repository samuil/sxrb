module SXRB
  class CallbackTreeNode
    attr_reader :children, :parent, :content_mode
    attr_writer :on_whole_element

    def initialize(options = {})
      set_options options
      @children = Hash.new {|h,k| h[k] = CallbackTreeNode.new(:parent => self)}
    end

    def set_options(options)
      @content_mode = options[:content]
      @parent = options[:parent]
    end

    def add(tag, options)
      Proxy.new(
        @children[tag].tap do |callback_tree_node|
          callback_tree_node.set_options options
        end
      )
    end

    def on_whole_element(node)
      @on_whole_element.call(node.attributes, node.value) if @on_whole_element
    end

    def child(name)
      @children.find {|k,v| k === name}.tap do |key, value|
        return value
      end
    end
  end
end
