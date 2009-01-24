require File.dirname(__FILE__) + '/spec_helper'
require 'merb_babel/string'

describe "MerbBabel::String" do
  it "should be able to substitute hash" do
    string = MerbBabel::String.new("My name is %{name}")
    string.should be_kind_of(::String)
    string.should be_respond_to(:%)
    (string % {:name => "Tom"}).should == "My name is Tom"
    (string % {'name' => "Bob"}).should == "My name is Bob"
  end
end
