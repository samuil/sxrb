require 'libxml'
require 'sxrb/node'

# This class provides callbacks for SAX API which are configured with sxrb DSL.

module SXRB
  class Callbacks
    #include LibXML::XML::SaxParser::VerboseCallbacks
    include LibXML::XML::SaxParser::Callbacks
    def initialize(callback_node)
      @callback_node = callback_node
      @document_stack = []
    end

    def on_start_element_ns(name, attributes, prefix, uri, namespaces)
      @callback_node = @callback_node.children[name]
      Node.new(name, attributes, prefix, uri, namespaces).tap do |node|
        @document_stack.push(node)
      end
    end

    def on_characters(chars)
      case @callback_node.content_mode
      when :array
        @document_stack.last.value ||= []
        @document_stack.last.value.tap do |ary|
          if ary.last.is_a? String
            ary.last << chars
          else
            ary << chars
          end
        end
      when :string
        @document_stack.last.value ||= ""
        @document_stack.last.value << chars
      end
    end

    def on_end_element_ns(name, prefix, uri)
      @document_stack.pop.tap do |node|
        raise SXRB::TagMismatchError if node.name != name
        @callback_node.on_whole_element(node)
      end
      @callback_node = @callback_node.parent
    end
  end
end
