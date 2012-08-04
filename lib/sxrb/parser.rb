require 'sxrb/callbacks'
require 'sxrb/proxy'

module SXRB
  class Parser
    def initialize(input, opts = {}, &block)
      raise ArgumentError.new("Block expected") if block.nil?
      options = {:mode => :string}.merge(opts)

      # Build rules tree

      rules_tree = Proxy.new.tap do |proxy|
	block.call(proxy)
      end

      parser = case options[:mode]
	       when :string
		 LibXML::XML::SaxParser.string(input)
	       end

      parser.callbacks = Callbacks.new(rules_tree)
      parser.parse
    end
  end
end
