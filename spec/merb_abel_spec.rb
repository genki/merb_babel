require File.dirname(__FILE__) + '/spec_helper'

Merb.load_dependencies(:environment => 'test')

Merb::Router.prepare do |r|
  r.match(/\/?(en\-US|en\-UK|es\-ES|es\-AR)?/).to(:locale => "[1]") do |l|
    l.match("/tests").to(:controller => "test_controller")
  end
  r.match(/\/?(en|es|fr|de)?/).to(:language => "[1]") do |l|
    l.match("/languages").to(:controller => "language_controller")
  end
end

class TestController < Merb::Controller
  include MLocale
  include ML10n
  
  before :set_locale
  def index; end
end

class LanguageController < Merb::Controller
  include MLocale
  include ML10n
  
  before :set_language
  def index; end
end


describe 'using set_locale before filter, ' do
  describe 'a controller' do
  
    describe 'locale' do
    
      it "should be set by default" do
        c = dispatch_to(TestController, :index)
        c.locale.should == 'en-US'
      end
  
      it "should be able to be set by passing a param" do
        c = dispatch_to(TestController, :index, :locale => 'fr-FR')
        c.locale.should == 'fr-FR'
      end
      
      it "should be able to be set using the session" do
        c = dispatch_to(TestController, :index) do |controller|
          controller.stub!(:session).and_return( :locale => "es-BO" )
        end
        c.locale.should == 'es-BO'
      end
      
      it "should be set using an url (when the routes are set properly)" do
        #c = get('tests')
        #c.locale.should == 'en-US'
        c = get('en-US/tests')
        c.locale.should == 'en-US'
        c = get('en-UK/tests')
        c.locale.should == 'en-UK'
      end
      
      it "should support longer locales (like zh-Hans-CN)" do
        c = dispatch_to(TestController, :index, :locale => 'zh-Hans-CN')
        c.locale.should == 'zh-hans-CN'
      end
    
    end
  
    describe 'language' do 
    
      it "should be set by default" do
        c = dispatch_to(TestController, :index)
        c.language.should == 'en'
      end
  
      it "should be able to be set by passing a param" do
        c = dispatch_to(TestController, :index, :language => 'fr')
        c.language.should == 'fr'
      end
    
      it "should bet set when a locale was set by params" do
        c = dispatch_to(TestController, :index, :locale => 'fr-FR')
        c.locale.should == 'fr-FR'
        c.language.should == 'fr'
      end
      
      it "should be set when a locale was set by params even with a long locale" do
        c = dispatch_to(TestController, :index, :locale => 'zh-Hans-CN')
        c.language.should == 'zh-hans'
      end
      
      it "should bet set when a locale was set by session" do
        c = dispatch_to(TestController, :index) do |controller|
          controller.stub!(:session).and_return( :locale => "es-BO" )
        end
        c.language.should == 'es'
      end
      
      it "should be set by the router" do
        c = get('fr/languages')
        c.language.should == 'fr'
        c.locale.should == 'en-US'
        # c = get('languages')
        # c.language.should == 'en'
      end
  
    end
  
    describe 'country' do

      it "should be set by default" do
        c = dispatch_to(TestController, :index)
        c.country.should == 'US'
      end
    
      it "should be able to be set by passing a param" do
        c = dispatch_to(TestController, :index, :country => 'ES')
        c.country.should == 'ES'
      end
      
      it "should bet set when a locale was set by params" do
        c = dispatch_to(TestController, :index, :locale => 'fr-FR')
        c.country.should == 'FR'
      end
      
      it "should bet set when a locale was set by session" do
        c = dispatch_to(TestController, :index) do |controller|
          controller.stub!(:session).and_return( :locale => "es-BO" )
        end
        c.country.should == 'BO'
      end
  
    end
    
  end
end

describe 'using set_language, ' do
  describe 'a controller' do
    describe 'language' do 
    
      it "should be set by default" do
        c = dispatch_to(LanguageController, :index)
        c.language.should == 'en'
      end
  
      it "should be able to be set by passing a param" do
        c = dispatch_to(LanguageController, :index, :language => 'fr')
        c.language.should == 'fr'
      end
  
    end
  end
end

describe ML10n do
  
  before(:each) do
    @lang_test_path = File.expand_path(File.dirname(__FILE__) + "/lang")
    @lang_test_path_2 = File.expand_path(File.dirname(__FILE__) + "/other_lang_dir")
    reset_localization_files_and_dirs!
  end
  
  it "should have a list of localization directories" do
    localization_dirs.should == Merb::Plugins.config[:merb_abel][:localization_dirs]
  end
  
  it "should be able to add a new localization directory" do
    add_localization_dir(@lang_test_path)
    localization_dirs.include?(@lang_test_path)
  end
  
  it "should have a list of localization source files" do
    localization_files.should == []
    add_localization_dir(@lang_test_path)
    localization_files.include?("#{@lang_test_path}/en.yml").should be_true
    localization_files.include?("#{@lang_test_path}/en-US.yml").should be_true
  end
  
  it "should load localization files and have them available" do
    add_localization_dir(@lang_test_path)
    load_localization!
    localizations['en'][:right].should == 'right'
    localizations['en'][:left].should == 'left'
    localizations['en']['US'][:greetings].should == 'Howdie'
  end
  
  it "should load more localization files and have them available" do
    add_localization_dir(@lang_test_path)
    load_localization!
    localizations['en'][:right].should == 'right'
    localizations.has_key?('fr').should be_false
    
    add_localization_dir(@lang_test_path_2)
    load_localization!
    localizations['en'][:right].should == 'right'
    localizations.has_key?('fr').should be_true
    localizations['fr'][:right].should == 'la droite'
    localizations['fr'][:left].should == 'la gauche'
    localizations['fr'][:greetings].should == 'Salut'
  end
  
end