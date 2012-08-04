require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SXRB::Parser do
  it 'should fail when created without block' do
    expect {
      SXRB::Parser.new("<xmlstring/>")
    }.to raise_error(ArgumentError)
  end

  context 'dsl' do
    it 'should call child blocks' do
      handler = double('handler')
      handler.should_receive(:msg).once

      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |testelement|
          handler.msg
        end
      end
    end
  end

  context 'callbacks' do
    it 'should call defined callback for child element' do
      handler = double('handler')
      handler.should_receive(:msg).once

      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |testelement|
          testelement.on_whole_element do |attrs, value|
            handler.msg
          end
        end
      end
    end
  end
end
