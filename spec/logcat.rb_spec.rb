require 'spec_helper'
require 'logcat.rb'

describe Logcat.rb do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
