require "rspec"
require "rspec_helper"

describe "KeyChain" do

	keyChain = nil

	before do
		keyChain = DesignShell::KeyChain.new('DesignShellTest')
	end

	it "should write,read,check value" do
		value = StringUtils.random_word(8,8)
		keyChain.set('testKey',value)
		readValue = keyChain.get('testKey')
		readValue.should == value
	end

	it "should support get and set with a prefix" do
		value1 = StringUtils.random_word(8,8)
		value2 = StringUtils.random_word(8,8)
		keyChain.set('testKey',value1)
		keyChain.set('testKey',value2,'blah')
		keyChain.get('testKey').should==value1
		keyChain.get('testKey','blah').should==value2
	end

	it "should support multiple get" do
		value1 = StringUtils.random_word(8,8)
		value2 = StringUtils.random_word(8,8)
		keyChain.set('testKey1',value1)
		keyChain.set('testKey2',value2)
		keyChain.get('testKey1').should==value1
		keyChain.get('testKey2').should==value2
		keyChain.get(['testKey1']).should=={'testKey1' => value1}
		keyChain.get(['testKey2']).should=={'testKey2' => value2}
		keyChain.get(['testKey1','testKey2']).should=={'testKey1' => value1,'testKey2' => value2}
		keyChain.get(%w(testKey1 testKey2)).should=={'testKey1' => value1,'testKey2' => value2}
	end

	it "should support multiple get with a prefix" do
		value1 = StringUtils.random_word(8,8)
		value2 = StringUtils.random_word(8,8)
		keyChain.set('testKey1','')
		keyChain.set('testKey2','')
		keyChain.set('testKey1',value1,'prefix1.')
		keyChain.set('testKey2',value2,'prefix1.')
		keyChain.get(%w(testKey1 testKey2)).should == {'testKey1' => '', 'testKey2' => ''}
		keyChain.get(%w(testKey1 testKey2),'prefix1.').should == {'testKey1' => value1, 'testKey2' => value2}
		keyChain.get(%w(testKey1 testKey2),'prefix1.',true).should == {'prefix1.testKey1' => value1, 'prefix1.testKey2' => value2}
	end

	it "should support multiple set" do
		value1 = StringUtils.random_word(8,8)
		value2 = StringUtils.random_word(8,8)
		keyChain.set({
			'testKey1' => value1,
		  'testKey2' => value2
		})
		keyChain.get('testKey1').should==value1
		keyChain.get('testKey2').should==value2
	end

DEPLOY_XML = <<EOS
<deploy>
	<kind>BigCommerce</kind>
	<method>WebDav</method>
	<fromPath>/build/bigcommerce</fromPath>
	<toPath>/</toPath>
	<item name="itemX">some item x</item>
	<item name="itemY" key="itemYYY">YYY</item>
	<item name="itemZ"></item>
	<item name="itemZZ"/>
</deploy>
EOS

	it "should support DesignShell::Utils.lookupItems" do
		values = {
			'itemX' => 'never read this',
			'itemY' => 'never read this',
			'itemYYY' => 'YYYYY',
			'itemZ' => 'ZZZ',
			'itemZZ' => 'ZZZZZ',
		}
		keyChain.set(values)
		deployXml = XmlUtils.get_xml_root(DEPLOY_XML)
		result = DesignShell::Utils.lookupItems(deployXml,keyChain)
		result['itemX'].should=='some item x'
		result['itemY'].should=='YYY'   # text value overrides keychain
		result['itemZ'].should==values['itemZ']
		result['itemZZ'].should==values['itemZZ']
	end

end