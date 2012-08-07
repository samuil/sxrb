module SXRB
  class Proxy
    # @api private
    def initialize(callback_tree, current_path = '')
      @callback_tree = callback_tree
      @current_path = current_path
    end

    # Defines child (a direct descendant) of an element defined in current.
    # block.
    # @param [String] *tags
    #   names of tags that should be matched
    #
    # @yield [Proxy]
    #   block receives Proxy element representing matched elements
    #
    # @return [nil]
    #
    # @api public
    #
    # @todo Add Regexp and other selectors support in addition to Strings.
    def child(*tags, &block)
      tags.each do |tag|
        @callback_tree.add_rule(tag, @current_path, :recursive => false).tap do |new_path|
          block.call(Proxy.new(@callback_tree, new_path))
        end
      end
    end

    # Defines descendant of an element defined in current block.
    # @param [String] *tags
    #   names of tags that should be matched
    #
    # @yield [Proxy]
    #   block receives Proxy element representing matched elements
    #
    # @return [nil]
    #
    # @api public
    #
    # @todo Add Regexp and other selectors support in addition to Strings.
    def descendant(*args, &block)
      args.each do |tag|
        @callback_tree.add_rule(tag, @current_path, :recursive => true).tap do |new_path|
          block.call(Proxy.new(@callback_tree, new_path))
        end
      end
    end

    # Defines callback method invoked when matching element is completely
    # parsed.
    # @yield [Node] block receives whole parsed element with children.
    #
    # @api public
    #
    # @note `on_element` should not be used for items that are expected to have
    # large node subtrees.
    def on_element(&block)
      @callback_tree.add_callback(:element, @current_path, &block)
    end

    # Defines a callback that is invoked whenever start tag is encountered.
    #
    # @yield [Node] block receives parsed node without any nested elements. All
    # inline attributes are available though.
    #
    # @api public
    def on_start(&block)
      @callback_tree.add_callback(:start, @current_path, &block)
    end

    # Defines a callback that is invoked whenever anonymous text node within
    # self is encountered.
    #
    # @yield [String] block receives raw content of parsed data in form of
    # String object.
    #
    # @api public
    def on_characters(&block)
      @callback_tree.add_callback(:characters, @current_path, &block)
    end

    # Defines a callback that is invoked whenever end tag is encountered.
    #
    # @yield [Node] block receives parsed node without any nested elements. All
    # inline attributes are available though.
    #
    # @api public
    def on_end(&block)
      @callback_tree.add_callback(:end, @current_path, &block)
    end

  end
end
