require 'sxrb/callbacks'
require 'sxrb/proxy'

module SXRB
  class Parser
    def initialize(input, opts = {}, &block)
      raise ArgumentError.new("Block expected") if block.nil?
      options = {:mode => :string}.merge(opts)

      # Build rules tree

      rules_tree = CallbackTreeNode.new.tap do |node|
        block.call(Proxy.new(node))
      end

      # Create parser according to options

      parser = case options[:mode]
               when :string
                 LibXML::XML::SaxParser.string(input)
               end

      # Go!

      parser.callbacks = Callbacks.new(rules_tree)
      parser.parse
    end
  end
end
