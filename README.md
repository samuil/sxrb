`sxrb` aims to provide nice DSL for ruby developers to cope with XML files that
are too big to be loaded at once with Nokogiri or other parser. It is based on
external SAX implementation.

This piece of code builds `links` map out of html document that contains arrays
of anchor texts related to each link.

```ruby
links = Hash.new {[]}

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
