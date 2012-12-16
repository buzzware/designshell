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
end