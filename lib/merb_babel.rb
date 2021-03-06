#require File.join(File.dirname(__FILE__) / "merb_babel" / "core_ext")

# make sure we're running inside Merb
if defined?(Merb::Plugins)
  
  require File.join(File.dirname(__FILE__), %w(merb_babel m_locale))
  require File.join(File.dirname(__FILE__), %w(merb_babel m_l10n))
  require File.join(File.dirname(__FILE__), %w(merb_babel m_i18n))
  require File.join(File.dirname(__FILE__), %w(merb_babel string))
  require File.join(File.dirname(__FILE__), %w(merb_babel time))
  require File.join(File.dirname(__FILE__), %w(merb_babel locale_detector))
  require File.join(File.dirname(__FILE__), %w(merb_babel storage))
  gem "locale"
  require 'locale'

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:merb_babel] = {
    :default_locale => 'en-US',
    :default_language => 'en',
    :default_country => 'US',
    :localization_dirs => ["#{Merb.root}/lang"]
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
    module Merb
      module GlobalHelpers

        # Used to translate words using localizations
        def babelize(*args)
          begin
            options = args.pop if args.last.kind_of?(Hash) 
            options ||= {}
            options[:language] ||= language
            options[:country] ||= country
            case key = args.last
            when Date, Time
              if args.size >= 2
                format = MI18n.lookup(options.merge(:keys => args[0..-2]))
                ML10n.localize_time(key, format, options)
              else
                MerbBabel::Time.new(key.to_time, options)
              end
            when Numeric
              ML10n.localize_ordinal(key, args[0..-2], options)
            else
              MI18n.lookup(options.merge(:keys => args))
            end
          end
        end
        alias :translate :babelize
        alias :t :babelize
        alias :_ :babelize
      end
    end
    
    Merb::Controller.send(:include, MLocale)
    #ML10n.load_localization!
    MerbBabel::Storage.load_localization!
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
  Merb::Plugins.add_rakefiles "merb_babel/merbtasks"
end
