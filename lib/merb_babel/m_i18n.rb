module MI18n
  
  def self.lookup(options)
    keys = options[:keys].map{|k| k.class == Symbol ? k.to_s : k}
    language = options[:language]
    country = options[:country]

    raise ArgumentError, "You need to pass a language reference" unless language
    raise ArgumentError, "You need to pass a localization key" if keys.empty?
    unless ML10n.localizations[language]
      language = Merb::Plugins.config[:merb_babel][:default_language]
    end
    raise ArgumentError,
      "language: #{language} not found" unless ML10n.localizations[language]
    
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
    lookup_with_hash(keys, ML10n.localizations[language])
  end
  
  def self.lookup_with_full_locale(keys, language, country)
    if ML10n.localizations.has_key?(language)
      ML10n.localizations[language].has_key?(country) ?
        lookup_with_hash(keys, ML10n.localizations[language][country]) : nil 
    else
      nil
    end
  end
  
  def self.lookup_with_hash(keys, l_hash)
    keys.inject(l_hash){|h,k| h[k] rescue nil}
  end
end
