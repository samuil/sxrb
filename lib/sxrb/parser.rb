require 'sxrb/callbacks'
require 'sxrb/proxy'

module SXRB
  # Main class of gem, which allows parsing XML data.
  class Parser
    # Cool
    # @param [Filename, IO, String] input
    #   Data stream to be parsed.
    # @option opts [Symbol] :mode (:string)
    #   Instructs SXRB how to treat input parameter. Possible values are:
    #   :string, :file, :io. Please note, that in case of :file mode
    #   input should be filename.
    #
    def initialize(input, opts = {}, &block)
      raise ArgumentError.new("Block expected") if block.nil?
      options = {:mode => :string}.merge(opts)

      # Create parser according to options

      parser = case options[:mode]
               when :string
                 LibXML::XML::SaxParser.string(input)
               when :file
                 LibXML::XML::SaxParser.file(input)
               when :io
                 LibXML::XML::SaxParser.io(input)
               end

      callbacks = Callbacks.new.tap do |cb|
        yield Proxy.new(cb)
      end

      parser.callbacks = callbacks
      parser.parse
    end
  end
end
