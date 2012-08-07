module SXRB
  # SXRB::TagMismatchError is raised whenever parser encounters closing tag of
  # never opened element.
  class TagMismatchError < StandardError; end
end
