require File.dirname(__FILE__) + '/spec_helper'

describe "MerbBabel::Storage" do
  before(:each) do
    @lang_test_path = File.expand_path(File.dirname(__FILE__) + "/lang")
    @lang_test_path_2 = File.expand_path(
      File.dirname(__FILE__) + "/other_lang_dir")
    MerbBabel::Storage.reset_localization_files_and_dirs!
  end

  after(:each) do
    MerbBabel::Storage.reset_localizations!
  end
  
  it "should have a list of localization directories" do
    MerbBabel::Storage.localization_dirs.should ==
      Merb::Plugins.config[:merb_babel][:localization_dirs]
  end
  
  it "should be able to add a new localization directory" do
    MerbBabel::Storage.add_localization_dir(@lang_test_path)
    MerbBabel::Storage.localization_dirs.include?(@lang_test_path)
  end
  
  it "should have a list of localization source files" do
    MerbBabel::Storage.localization_files.should == []
    MerbBabel::Storage.add_localization_dir(@lang_test_path)
    MerbBabel::Storage.localization_files.include?(
      "#{@lang_test_path}/en.yml").should be_true
    MerbBabel::Storage.localization_files.include?(
      "#{@lang_test_path}/en-US.yml").should be_true
  end
  
  it "should load localization files and have them available" do
    MerbBabel::Storage.add_localization_dir(@lang_test_path)
    MerbBabel::Storage.load_localization!
    MerbBabel::lookup('en', 'right').should == 'right'
    MerbBabel::lookup('en', 'left').should == 'left'
    MerbBabel::lookup('en', 'US', 'greetings').should == 'Howdie'
  end
  
  it "should load more localization files and have them available" do
    MerbBabel::Storage.add_localization_dir(@lang_test_path)
    MerbBabel::Storage.load_localization!
    MerbBabel::lookup('en', 'right').should == 'right'
    MerbBabel::should_not be_exist('fr')
    
    MerbBabel::Storage.add_localization_dir(@lang_test_path_2)
    MerbBabel::Storage.load_localization!
    MerbBabel::lookup('en', 'right').should == 'right'
    MerbBabel::should be_exist('fr')
    MerbBabel::lookup('fr', 'right').should == 'la droite'
    MerbBabel::lookup('fr', 'left').should == 'la gauche'
    MerbBabel::lookup('fr', 'greetings').should == 'Salut'
  end
end
