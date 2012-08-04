module SXRB
  class Node < Struct.new(:name, :attributes, :prefix, :uri, :namespaces, :value)
  end
end
