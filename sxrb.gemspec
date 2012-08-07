Gem::Specification.new do |s|
  s.name        = 'sxrb'
  s.version     = '0.2.2'
  s.date        = '2012-08-07'
  s.summary     = "Smart XML parser"
  s.description = "Robust XML parser that allows defining desired behavior with fancy DSL"
  s.authors     = ["Bartek Borkowski"]
  s.files       = ["lib/sxrb/text_node.rb", "lib/sxrb/callbacks.rb",
    "lib/sxrb/node.rb", "lib/sxrb/parser.rb", "lib/sxrb/errors.rb",
    "lib/sxrb/proxy.rb", "lib/sxrb.rb"]
  s.homepage    = 'http://rubygems.org/gems/sxrb'
  s.add_runtime_dependency 'libxml-ruby', '~> 2.3.3'
  s.license     = 'MIT'
  s.test_files  = ['spec/parser_spec.rb']
end
