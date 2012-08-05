module SXRB
  class Proxy
    def initialize(callback_tree, current_path = '')
      @callback_tree = callback_tree
      @current_path = current_path
    end

    def child(*args, &block)
      options = {:recursive => false}.merge(args.last.is_a?(Hash) ? args.pop : {})
      args.each do |tag|
        @callback_tree.add_rule(tag, @current_path, options).tap do |new_path|
          block.call(Proxy.new(@callback_tree, new_path))
        end
      end
    end

    def descentant(*args, &block)
      options = {:recursive => true}.merge(args.last.is_a?(Hash) ? args.pop : {})
      args.each do |tag|
        @callback_tree.add_rule(tag, @current_path, options).tap do |new_path|
          block.call(Proxy.new(@callback_tree, new_path))
        end
      end
    end

    def on_element(&block)
      @callback_tree.add_callback(:element, @current_path, &block)
    end

    def on_element_start(&block)
      @callback_tree.add_callback(:start, @current_path, &block)
    end

    def on_element_end(&block)
      @callback_tree.add_callback(:end, @current_path, &block)
    end

  end
end
