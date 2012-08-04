`sxrb` aims to provide nice DSL for ruby developers to cope with XML files that
are too big to be loaded at once with Nokogiri or other parser. It is based on
external SAX implementation.

DSL instructing `sxrb` how to treat encountered entities is very similar to one
that would be usually used to build parsed document, which makes it very easy
to represent business logic behind the code.

Given `html` variable containing string with any webpage code this piece of
code builds `links` Hash that contains arrays of anchor texts related to each
link.

```ruby
links = Hash.new {|h,k| h[k] = []}

SXRB::Parser.new(html) do |html|
  html.child 'body' do |body|
    body.descendant 'a' do |a|
      a.on_whole_element do |attrs, value|
        links[attrs[:href]] << value
      end
    end
  end
end
```
