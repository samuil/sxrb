require 'libxml'
require 'sxrb/node'
require 'sxrb/text_node'

# This class provides callbacks for SAX API which are configured with sxrb DSL.

module SXRB
  class Callbacks
    #include LibXML::XML::SaxParser::VerboseCallbacks
    include LibXML::XML::SaxParser::Callbacks
    def initialize
      @stack = []
      @rules_map = Hash.new {|h,k| h[k] = Rules.new}
    end

    def on_start_element_ns(name, attributes, prefix, uri, namespaces)
      Node.new(name, attributes, prefix, uri, namespaces).tap do |node|
        @stack.push(node)
        invoke_callback(:start, node)
        @current_element.append node if @current_element
        @current_element = node if current_matching_rules.any?(&:recursive) || @current_element
      end
    end

    def on_characters(chars)
      if @stack.last.is_a? TextNode
        @stack.last.append_text chars
      else
        TextNode.new(chars).tap do |node|
          @stack.push node
          @current_element.append node if @current_element
        end
      end
      invoke_callback(:characters, chars)
    end

    def on_end_element_ns(name, prefix, uri)
      @stack.pop if @stack.last.is_a? TextNode

      if @current_element
        invoke_callback(:element, @current_element) if current_matching_rules.any?(&:recursive)
        @current_element = @current_element.parent
      end

      @stack.pop.tap do |node|
        raise SXRB::TagMismatchError if node.name != name
        invoke_callback(:end, node)
      end
    end

    def add_callback(type, rule_path, &block)
      @rules_map[Regexp.new "#{rule_path}$"].tap do |rules|
        rules.rules[type] = block
        rules.recursive = (type == :element) # true / false
      end
    end

    # options:
    #   recursive
    #
    def add_rule(rule, rule_path, opts)
      options = {:recursive => false}.merge opts
      operator = options[:recursive] ? ' ' : '.*'
      new_rule = rule_path + operator + rule
      new_rule
    end

    private

    def invoke_callback(type, *args)
      current_matching_rules.
        map {|value| value.rules[type]}.
        compact.each {|callback| callback.call(*args)}
    end

    def current_matching_rules
      @rules_map.each_pair.
        select {|rule, value| current_rule_path =~ rule}.
        map {|rule, value| value}
    end

    def current_rule_path
      @stack.map(&:name).join(' ')
    end
  end

  class Rules
    attr_accessor :rules, :recursive
    def initialize
      @rules = {}
      @recursive = false
    end
  end
end
