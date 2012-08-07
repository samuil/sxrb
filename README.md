About
=====

`SXRB` aims to provide nice DSL for ruby developers to cope with XML files that
are too big to be loaded at once with Nokogiri or other parser. It is based on
external `SAX` implementation.

DSL instructing `SXRB` how to treat encountered entities is very similar to one
that would be usually used to build parsed document, which makes it very easy
to represent business logic behind the code.

With `SXRB` one can write readable code that handles XML data, which later runs
fast and has low memory usage. DSL combines SAX robustness with DOM simplicity.

For quick start install `SXRB` with:

    gem install sxrb

[![Build Status](https://secure.travis-ci.org/samuil/sxrb.png)](http://travis-ci.org/samuil/sxrb)

Few examples
=============

Parsing html
------------

Given `html` variable containing string with any webpage code this piece of
code builds `links` Hash that contains arrays of anchor texts related to each
link.

```ruby
require 'sxrb'

html = <<-HTML
<html>
  <body>
    <a href="https://github.com/samuil/sxrb">SXRB</a>
  </body>
</html>
HTML

links = Hash.new {|h,k| h[k] = []}

SXRB::Parser.new(html) do |html|
  html.descendant 'body' do |body|
    body.descendant 'a' do |a|
      a.on_element do |element|
        links[element.attributes['href']] << element.content
      end
    end
  end
end
```

Typical `SAX` application
-------------------------

If you have ever used `SAX` before you should be familiar with idea of event
that it provides. `SXRB` wraps those events, so usually you won't need them,
but they are still available. Elements in DSL provide `on_start` and `on_end`
methods, that call provided block whenever matching element is encountered (at
beginning and end of the tag respectively).

```ruby
counter = 0
SXRB::Parser.new(file, :mode => :file) do |xml|
  xml.descendant 'test_element' do |el|
    el.on_start {counter += 1}
  end
end
```

Few details
==============

As you could see in above examples DSL provides `on_element` method which is
easy-to-use wrapper of internal `SAX` events. This method changes the way
parser treats incoming data when matching element is encountered. All events
within this element are used to build small DOM-like structure, which is more
comfortable than typical series of events. Please note that without additional
memory usage you can define nested `on_element` blocks.

Disclaimer
==========

`SXRB` is in early development stage (currently released version is 0.2.2). It is not yet
production-ready, because of a bit unstable API (versioning convention is
maintained though -- minor upgrades don't break compatibility). I'm planning to
end wild development, stabilize API and have full test suite with version 1.0.0.

License
=======

`SXRB` is distributed under MIT license (see LICENSE for details).
