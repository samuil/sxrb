module SXRB
  class Node < Struct.new(:name, :attributes, :prefix, :uri, :namespaces)
  end
end
