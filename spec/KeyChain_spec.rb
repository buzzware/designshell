require "rspec"
require "rspec_helper"

describe "KeyChain" do

	keyChain = nil

	before do
		keyChain = Dash::KeyChain.new('DashTest')
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

end