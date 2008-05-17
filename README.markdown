MerbAbel
=========

A plugin for the Merb framework that provides locales, languages, countries. (multi threaded)


Purpose of MerbAbel
---------------------

MerbAbel is primarily written to fulfill my personal needs. Instead of porting my http://github.com/matta/globalite plugin over, I decided to re write it from scratch learning from my mistakes.

Goals:

* simplicity
* speed

My first and simple objective is to get Merb to work in Simplified and Traditional Chinese + switch from one to the other.

Also, as of today, I'm not planning on supporting model localization since I believe it's easy to do, and in most cases it's too specific to use a plugin. (but other plugins offer that for you anyway ;) )

One of the objectives is that people can require MerbAbel and use merb in a different language without worrying about internationalization/localization. I hope to keep merb helpers and other plugins (merb_activerecord / merb_datamapper) localized so someone can define his app's locale/language/country and Merb will talk his language right away.

Before you go further, you might want to read [this explanation about i18n/l10n](http://www.w3.org/International/questions/qa-i18n)

Usage
------

In your application controller add:

    before :set_locale
    

and access the user locale using  @controller.locale (or simply #locale in the controller)
If a locale is set, you can also access @controller.language and @controller.country (same thing, you can use #language or #country from within your controller scope)

The locale is stored in request.env[:locale]

At the moment you have 3 ways of setting up a locale:

* default way in the config settings (that you can overwrite in your init.rb file )

    Merb::Plugins.config[:MerbAbel] = {
      :default_locale => 'en-US',
      :default_language => 'en',
      :default_country => 'US'
    }
    
* per request basis, by sending a param called locale (language, and country will set their own values)
* store the locale in the session
* use routes

Abel doesn't support http header lookup yet.

Set locale in your routes
--------------------------

    r.match(/\/?(en\-US|en\-UK|es\-ES|es\-AR)?/).to(:locale => "[1]") do |l|
      l.match("/articles/:action/:id").to(:controller => "articles")
    end
    
What if you don't need to use a full locale?
--------------------------------------------

some people might not need to use the full locale, they just want to use one version of a language and the locale is an overkill. Don't worry, you can use the language instance variable.

    before :set_language
    
    
All locale work is done in merb_abel/lib/merb_abel/m_locale.rb and tested in spec/merb_abel_spec    

Localization(L10n)
------------------

L10n is basically the adaptation of your product to a specific locale. In our case, we see L10n as the storing and retrieval of localized data. (for a locale or language)

Localizations are loaded from the localization files.

Localization files are simple yaml files that get loaded in memory. By default MerbAbel will look in ./lang for localization files. The default location is defined in Merb::Plugins.config[:merb_abel][:localization_dirs] and can be overwritten. Also, you can add more folders to look for by calling:

    add_localization_dir(path_with_more_localization_files)
    
Note: when you add a new localization directory, localizations gets reloaded.

Localizations are available in #localizations and are namespaced as follows:

    localizations['en'][:right] => 'right'
    localizations['en'][:left] => 'left'
    localizations['en']['US'][:greeting] => 'Howdie'
    localizations['en']['AU'][:greeting] => "Good'ay"
    
For that the localization files to be loaded properly, you need to follow some conventions:

* you have to declare a merb localization language code pair: 
    mloc_language_code: en
where en represents the language code of the localization

* All generic localization for a language should go under their own language file. Region/culture specific localizations have to go to their own files and will be used if the full locale is set.

* A localization file is recognized as being locale specific if the mloc_country_code pair is set.

* ONLY localizations/translations specific to a locale should be in the locale loc file.

* Recommended: set the mloc_language_name pair so you list the available languages in their own language.

* look at examples in spec/lang

All the Localization(L10n) work is done in merb_abel/lib/merb_abel/m_l10n.rb and tested in spec/merb_abel_spec


Internationalization(I18n)
--------------------------

I18n enables easy localization of your product. That's what the developer/designer user to make their data localizable.

TODO



Other plugins you might want to look at:
----------------------------------------

* http://github.com/myabc/merb_global
* http://github.com/lemon/poppycock