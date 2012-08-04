require 'libxml'
require 'sxrb/node'

# This class provides callbacks for SAX API which are configured with sxrb DSL.

module SXRB
  class Callbacks
    #include LibXML::XML::SaxParser::VerboseCallbacks
    include LibXML::XML::SaxParser::Callbacks
    def initialize(callback_tree)
      @callback_tree = callback_tree
      @document_stack = []
    end

    def on_start_element_ns(name, attributes, prefix, uri, namespaces)
      super
      Node.new(name, attributes, prefix, uri, namespaces).tap do |node|
	@document_stack.push(node)
      end
    end

    def on_end_element_ns(name, prefix, uri)
      super
      @document_stack.pop.tap do |node|
	raise SXRB::TagMismatchError if node.name != name
      end
    end
  end
end
