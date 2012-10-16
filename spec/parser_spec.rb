require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SXRB::Parser do
  context 'constructors' do
    it 'should fail when created without block' do
      expect {
        SXRB::Parser.new("<xmlstring/>")
      }.to raise_error(ArgumentError)
    end

    it 'should allow reusing defined rules' do
      @handler = double('handler')
      @handler.should_receive(:msg).twice
      rules = SXRB::Parser.define_rules do |root|
        root.child("el") do |el|
          el.on_element {@handler.msg}
        end
      end
      SXRB::Parser.parse_string('<el></el>', rules)
      SXRB::Parser.parse_string('<el></el>', rules)
    end
  end

  context 'matchers' do
    let(:probe) { lambda{} }

    it 'should call defined start callback for child element' do
      probe.should_receive(:call).once
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_start(&probe)
        end
      end
    end

    it 'should call defined end callback for child element' do
      probe.should_receive(:call).once
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_end(&probe)
        end
      end
    end

    it 'should call defined characters callback for child element' do
      probe.should_receive(:call).once
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_characters(&probe)
        end
      end
    end

    it 'should call defined element callback for child element' do
      probe.should_receive(:call).once
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element(&probe)
        end
      end
    end

    it 'should call defined element callback for child element only' do
      probe.should_receive(:call).once
      SXRB::Parser.new("<testelement><testelement>content</testelement></testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element(&probe)
        end
      end
    end

    it 'should call defined element callback for all descendants' do
      probe.should_receive(:call).twice
      SXRB::Parser.new("<testelement><testelement>content</testelement></testelement>") do |xml|
        xml.descendant 'testelement' do |test_element|
          test_element.on_element(&probe)
        end
      end
    end

    it 'should call callback for element regardless of nested elements' do
      probe.should_receive(:call).once
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element(&probe)
        end
      end
    end

    it 'should not invoke callback for child which isn\'t direct descendant' do
      probe.should_not_receive(:call)
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'a' do |a|
          a.on_element(&probe)
        end
      end
    end

    it 'should invoke callback for nested child' do
      probe.should_receive(:call).once
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'testelement' do |testelement|
          testelement.child 'a' do |a|
            a.on_element(&probe)
          end
        end
      end
    end

    it 'should not find element with non-matching name' do
      probe.should_not_receive(:call)
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'othername' do |test_element|
          test_element.on_element(&probe)
        end
      end
    end

    it 'should find element by regexp' do
      pending "feature not ready yet"
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child /testel/ do |test_element|
          test_element.on_element(&probe)
        end
      end
    end

    context 'css' do
      it 'should find direct descendant' do
        pending "feature not ready yet"
        SXRB::Parser.new("<testelement><a>content<a></testelement>") do |xml|
          xml.css "testelement > a" do |test_element|
            test_element.on_element(&probe)
          end
        end
      end
    end
  end

  context 'passed values' do
    it 'should pass empty hash to callback when no attributes are given' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |element|
            element.attributes.should == {}
          end
        end
      end
    end

    it 'should pass attributes properly to on_start callback' do
      SXRB::Parser.new('<testelement foo="bar">content</testelement>') do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_start do |element|
            element.attributes.should == {'foo' => 'bar'}
          end
        end
      end
    end

    it 'should pass attributes properly to on_element callback' do
      SXRB::Parser.new('<testelement foo="bar">content</testelement>') do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |element|
            element.attributes.should == {'foo' => 'bar'}
          end
        end
      end
    end

    it 'should pass attributes properly to on_end callback' do
      SXRB::Parser.new('<testelement foo="bar">content</testelement>') do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_end do |element|
            element.attributes.should == {'foo' => 'bar'}
          end
        end
      end
    end

    it 'should pass concatenated content' do
      SXRB::Parser.new("<testelement><a>con</a>tent</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |element|
            element.content == 'content'
          end
        end
      end
    end

    it 'should pass value properly to callback to on_element' do
      SXRB::Parser.new("<testelement>content</testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |element|
            element.content == 'content'
          end
        end
      end
    end

    it 'should find nested element' do
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.child 'a' do |a|
            a.on_element do |element|
              element.content == 'a-content'
            end
          end
        end
      end
    end

    it 'should pass nested elements content on_element callback' do
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |node|
            node.content.should == 'a-content'
          end
        end
      end
    end

    it 'should pass nested elements to on_element callback' do
      SXRB::Parser.new("<testelement><a>a-content</a></testelement>") do |xml|
        xml.child 'testelement' do |test_element|
          test_element.on_element do |element|
            element.children.first.tap do |a|
              a.name.should == 'a'
              a.content.should == 'a-content'
            end
          end
        end
      end
    end
  end
end
