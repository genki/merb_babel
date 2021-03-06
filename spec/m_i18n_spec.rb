require File.dirname(__FILE__) + '/spec_helper'
  
describe '#babelize' do
  
  before(:each) do
    Merb::Controller.send :include, Merb::GlobalHelpers
    @c = dispatch_to(TestController, :index)
    MerbBabel::Storage.add_localization_dir(
      File.expand_path(File.dirname(__FILE__) + "/lang"))
    MerbBabel::Storage.add_localization_dir(
      File.expand_path(File.dirname(__FILE__) + "/other_lang_dir"))
    MerbBabel::Storage.load_localization!
  end

  after(:each) do
    MerbBabel::Storage.reset_localizations!
  end

  it "should babelize a word in English " do
    @c.locale.should == 'en-US'
    @c.language.should == 'en'
    @c.country.should == 'US'
    @c.babelize(:left).should == 'left'
  end
  
  it "should translate a word in English" do
    @c.t(:left).should == 'left'
    @c.translate(:left).should == 'left'
    @c._(:left).should == 'left'
  end
  
  it "should translate a word in american English" do
    @c.t(:greetings).should == 'Howdie'
  end
  
  it "should translate a word in british English" do
    @c.request.env[:locale] = 'en-UK'
    @c.t(:greetings).should == 'Heya'
  end
  
  it "should translate a word in French" do
    @c.request.env[:language] = 'fr'
    @c.t(:greetings).should == 'Salut'
  end
  
  it "should translate passing the full locale" do
    @c.t(:greetings, :language => 'en', :country => 'UK').should == 'Heya'
    @c.t(:greetings, :language => 'en', :country => 'US').should == 'Howdie'
  end
  
  it "should translate passing the language" do
    @c.t(:greetings, :language => 'fr').should == 'Salut'
  end

  it "should see mloc_country_code" do
    @c.t("城", :language => 'ja').should == "しろ"
    @c.t("城", :language => 'ja', :country => 'Okinawa').should == "ぐすく"
  end

  it "should translate with domain" do
    @c.t(:night, :greetings, :language => 'en').should == 'Good evening'
    @c.t(:night, :greetings, :language => 'ja').should == 'こんばんわ'
    @c.t(:night, :greetings, :language => 'tlh').should == 'Good evening'
  end

  it "should localize date" do
    date = Date.new(2009,1,1)
    @c.t("%Y/%m/%d", date, :language => 'en').should == "2009/01/01"
    @c.t("%Y/%{mon}/%{day}", date, :language => 'en').should == "2009/1/1"
    @c.t("%a/%d", date, :language => 'en').should == "T/01"
    @c.t("%a/%d", date, :language => 'en', :country => 'UK').should == "T/01"
    @c.t("%a/%d", date, :language => 'ja').should == "木/01"
    @c.t("%A", date, :language => 'ja').should == "木曜日"
    @c.t("%b", date, :language => 'en').should == "Jan"
    @c.t("%B", date, :language => 'en').should == "January"
    @c.t("%B", date, :language => 'ja').should == "１月"
  end

  it "should localize time" do
    time = Time.now
    if time.hour < 12
      @c.t("%p", time, :language => "ja").should == "午前"
      @c.t("%p", time, :language => "en").should == "AM"
    else
      @c.t("%p", time, :language => "ja").should == "午後"
      @c.t("%p", time, :language => "en").should == "PM"
    end
  end

  it "should localize time by using default yml if correct one is lacking" do
    date = Date.new(2009,1,1)
    @c.t("%B", date, :language => 'tlh').should == "January"
  end

  it "should return MerbBabel::String" do
    @c.t("Hello").class.should == MerbBabel::String
  end

  it "should localize detecting plural or singular" do
    keys = ["%d book", "%d books"]
    @c.t(keys, 1).should == "1 book"
    @c.t(keys, 2).should == "2 books"
    @c.t(keys, 3).should == "3 books"
    @c.t(keys, 0).should == "0 books"
    @c.t(keys, -1).should == "-1 books"
  end

  it "should localize time_lost_in_words" do
    @c.t(Time.now).class.should == MerbBabel::Time
    @c.t(DateTime.now).class.should == MerbBabel::Time
    @c.t(Time.now - 3*60).lost_in_words.should == "3 minutes"
    @c.t(Time.now - 3*60, :language => 'en', :country => "UK").lost_in_words.should == "3 minutes"
  end
end
