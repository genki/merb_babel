module MI18n
  
  def self.lookup(options)
    keys = options[:keys].map{|k| k.class == Symbol ? k.to_s : k}
    language = options[:language]
    country = options[:country]

    raise ArgumentError, "You need to pass a language reference" unless language
    raise ArgumentError, "You need to pass a localization key" if keys.empty?
    unless MerbBabel::localizations[language]
      language = Merb::Plugins.config[:merb_babel][:default_language]
    end
    raise ArgumentError,
      "language: #{language} not found" unless MerbBabel.localizations[language]
    
    full_location = nil
    full_location = lookup_with_full_locale(keys, language, country) if country
    
    result = full_location || lookup_with_language(keys, language) || keys.last
    case result
    when String
      MerbBabel::String.new(result)
    else result
    end
  end

  def self.lookup_with_language(keys, language)
    lookup_with_hash(keys, MerbBabel.localizations[language])
  end
  
  def self.lookup_with_full_locale(keys, language, country)
    if MerbBabel.localizations.has_key?(language)
      MerbBabel.localizations[language].has_key?(country) ?
        lookup_with_hash(keys,
          MerbBabel.localizations[language][country]) : nil 
    else
      nil
    end
  end
  
  def self.lookup_with_hash(keys, l_hash)
    keys.inject(l_hash){|h,k| h[k] rescue nil}
  end
end
