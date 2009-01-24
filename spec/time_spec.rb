require File.dirname(__FILE__) + '/spec_helper'
require 'merb_babel/time'

describe "MerbBabel::Time" do
  before(:each) do
    Merb::Controller.send :include, Merb::GlobalHelpers
    @c = dispatch_to(TestController, :index)
    ML10n.add_localization_dir(
      File.expand_path(File.dirname(__FILE__) + "/lang"))
    ML10n.add_localization_dir(
      File.expand_path(File.dirname(__FILE__) + "/other_lang_dir"))
    ML10n.load_localization!
  end

  after(:each) do
    ML10n.reset_localizations!
  end

  it "should be able to be converted into words" do
    time_ago = proc{|ago| MerbBabel::Time.new(Time.now - ago, @c)}
    time_ago[1*60].ago_in_words.should == "1 minute"
    time_ago[3*60].ago_in_words.should == "3 minutes"
    time_ago[20].ago_in_words.should == "less than a minute"
    time_ago[1].ago_in_words.should == "less than a minute"
    time_ago[50*60].ago_in_words.should == "about 1 hour"
    time_ago[2*60*60].ago_in_words.should == "about 2 hours"
    time_ago[24*60*60].ago_in_words.should == "1 day"
    time_ago[2*24*60*60].ago_in_words.should == "2 days"
    time_ago[22*24*60*60].ago_in_words.should == "22 days"
    time_ago[30*24*60*60].ago_in_words.should == "about 1 month"
    time_ago[4*30*24*60*60].ago_in_words.should == "4 months"
    time_ago[13*30*24*60*60].ago_in_words.should == "about 1 year"
    time_ago[3.5*12*30*24*60*60].ago_in_words.should == "over 3 years"
    options = {:include_seconds => true}
    time_ago[1].ago_in_words(options).should == "less than 5 seconds"
    time_ago[6].ago_in_words(options).should == "less than 10 seconds"
    time_ago[16].ago_in_words(options).should == "less than 20 seconds"
    time_ago[26].ago_in_words(options).should == "half a minute"
    time_ago[56].ago_in_words(options).should == "less than a minute"
  end
end
