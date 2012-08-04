module SXRB
  class Proxy
    def initialize
      @callbacks = Hash.new
    end

    def child(*args, &block)
      options = args.pop if args.last.is_a? Hash
      block.call(Proxy.new)
    end

    def on_whole_element(&block)
      @callbacks[:on_whole_element] = block
    end
  end
end
