require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SXRB::Parser do
  it 'should fail when created without block' do
    expect {
      SXRB::Parser.new("<xmlstring/>")
    }.to raise_error(ArgumentError)
  end

  context 'callbacks' do
    it 'should call defined callback for child element' do
      handler = double('handler')
      handler.should_receive(:msg).once

      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |element|
            handler.msg
          end
        end
      end
    end

    it 'should pass empty hash to callback when no attributes are given' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |element|
            element.attributes.should == {}
          end
        end
      end
    end

    it 'should pass value properly to callback in array mode' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement', :content_mode => :array do |test_element|
          test_element.on_element do |element|
            element.children.first.text == 'content'
          end
        end
      end
    end

    it 'should pass value properly to callback in string mode' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement', :content_mode => :string do |test_element|
          test_element.on_element do |element|
            element.children.first.text == 'content'
          end
        end
      end
    end

    it 'should not find element with non-matching name' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'othername', :content_mode => :string do |test_element|
          test_element.on_element do |attrs, value|
            value.should == 'content'
          end
        end
      end
    end

    it 'should find element by regexp' do
      pending "feature not ready yet"
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child /testel/, :content_mode => :string do |test_element|
          test_element.on_element do |attrs, value|
            value.should == 'content'
          end
        end
      end
    end

    it 'should find nested element' do
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.child 'a', :content_mode => :string do |a|
            a.on_element do |element|
              element.children.first.text == 'a-content'
            end
          end
        end
      end
    end

    it 'should call callback for element regardless of nested elements' do
      handler = double('handler')
      handler.should_receive(:msg).once
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |element|
            handler.msg
          end
        end
      end
    end

    it 'should pass nested elements to on_element callback' do
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'testelement', :content_mode => :array do |test_element|
          test_element.on_element do |element|
            element.children.first.tap do |a|
              a.name.should == 'a'
              a.children.first.text.should == 'a-content'
            end
          end
        end
      end
    end
  end
end
