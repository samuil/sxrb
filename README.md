`sxrb` aims to provide nice DSL for ruby developers to cope with XML files that are too big to be loaded at once with Nokogiri or other parser. It is based on external SAX implementation.


```ruby
SXRB.parse do |xml|
  xml.accept('programme', mode: whole_element) do |programme|
    programme.accept 'title', 'desc', 'date', 'category', mode: parent
    programme.accept 'catchup'
  end
end
```
