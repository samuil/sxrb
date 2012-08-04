module SXRB
  class Proxy
    def initialize(callback_tree_node)
      @callbacks = callback_tree_node
    end

    def child(*args, &block)
      options = args.pop if args.last.is_a? Hash
      args.each do |tag|
        @callbacks.add(tag).tap do |proxy|
          block.call(proxy)
        end
      end
    end

    def on_whole_element(&block)
      @callbacks.on_whole_element = block
    end
  end
end
