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
          test_element.on_whole_element do |attrs, value|
            handler.msg
          end
        end
      end
    end

    it 'should pass empty hash to callback when no attributes are given' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_whole_element do |attrs, value|
            attrs.should == {}
          end
        end
      end
    end

    it 'should pass value properly to callback in array mode' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement', :content => :array do |test_element|
          test_element.on_whole_element do |attrs, value|
            value.should == ['content']
          end
        end
      end
    end

    it 'should pass value properly to callback in string mode' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement', :content => :string do |test_element|
          test_element.on_whole_element do |attrs, value|
            value.should == 'content'
          end
        end
      end
    end

  end
end
