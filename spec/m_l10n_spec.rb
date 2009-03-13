require File.dirname(__FILE__) + '/spec_helper'

describe "ML10n" do
  before do
    MerbBabel::Storage.add_localization_dir(
      File.expand_path(File.dirname(__FILE__) + "/lang"))
    MerbBabel::Storage.add_localization_dir(
      File.expand_path(File.dirname(__FILE__) + "/other_lang_dir"))
    MerbBabel::Storage.load_localization!
  end

  after do
    MerbBabel::Storage.reset_localizations!
  end

  it "should localize ordinal" do
    ML10n.localize_ordinal(1, [["%d book", "%d books", "no books"]],
      :language => 'en').should == "1 book"
    ML10n.localize_ordinal(2, [["%d book", "%d books", "no books"]],
      :language => 'en').should == "2 books"
    ML10n.localize_ordinal(0, [["%d book", "%d books"]],
      :language => 'en').should == "0 books"
    ML10n.localize_ordinal(0, [["%d book", "%d books", "no books"]],
      :language => 'en').should == "no books"
  end

  it "should localize time" do
    date = Date.new(2009, 3, 14)
    ML10n.localize_time(date, "%B", :language => 'en').should == "March"
  end
end
