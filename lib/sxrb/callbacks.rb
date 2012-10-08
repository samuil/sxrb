require 'libxml'
require 'sxrb/node'
require 'sxrb/text_node'
require 'sxrb/rule_tree'


module SXRB

  # This class provides callbacks for SAX API which are configured with sxrb
  # DSL. It's behavior is configured by DSL via Proxy class objects, and should
  # not be used outside of this scope. Currently it has only been tested with
  # LibXML implementation of SAX, but set of method that object needs to
  # provide is defined by standard, so using it with different backend should
  # be automatic.
  class Callbacks
    #include LibXML::XML::SaxParser::VerboseCallbacks
    include LibXML::XML::SaxParser::Callbacks
    # @api private
    def initialize
      @stack = []
      @rules_map = Hash.new {|h,k| h[k] = Rules.new}
    end

    # @api private
    def on_start_element_ns(name, attributes, prefix, uri, namespaces)
      Node.new(name, attributes, prefix, uri, namespaces).tap do |node|
        @stack.push(node)
        invoke_callback(:start, node)
        @current_element.append node if @current_element
        @current_element = node if current_matching_rules.any?(&:recursive) || @current_element
      end
    end

    # @api private
    def on_characters(chars)
      if @stack.last.is_a? TextNode
        @stack.last.append_text chars
      else
        TextNode.new(chars).tap do |node|
          invoke_callback(:characters, node)
          @stack.push node
          @current_element.append node if @current_element
        end
      end
    end

    # @api private
    def on_end_element_ns(name, prefix, uri)
      @stack.pop if @stack.last.is_a? TextNode

      if @current_element
        invoke_callback(:element, @current_element) if current_matching_rules.any?(&:recursive)
        @current_element = @current_element.parent
      end

      invoke_callback(:end, @stack.last)
      @stack.pop.tap do |node|
        raise SXRB::TagMismatchError if node.name != name
      end
    end

    # @api private
    def add_callback(type, rule_path, &block)
      @rules_map[Regexp.new "^#{rule_path}$"].tap do |rules|
        rules.rules[type] = block
        rules.recursive = (type == :element) # true / false
      end
    end

    # @api private
    def add_rule(rule, rule_path, options)
      operator = options[:recursive] ? '.*' : ' '
      new_rule = rule_path + operator + rule
      new_rule.strip
    end

    private

    # @api private
    def invoke_callback(type, *args)
      current_matching_rules.
        map {|value| value.rules[type]}.
        compact.each {|callback| callback.call(*args)}
    end

    # @api private
    def current_matching_rules
      @rules_map.each_pair.
        select {|rule, value| current_rule_path =~ rule}.
        map {|rule, value| value}
    end

    # @api private
    def current_rule_path
      @stack.map(&:name).join(' ')
    end
  end

  # Internal class that is designed to keep rules of matching XML elements.
  # @api private
  class Rules
    attr_accessor :rules, :recursive
    def initialize
      @rules = {}
      @recursive = false
    end
  end
end
