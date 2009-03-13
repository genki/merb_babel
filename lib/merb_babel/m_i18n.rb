module MI18n
  
  def self.lookup(options)
    keys = options[:keys].map{|k| k.class == Symbol ? k.to_s : k}
    language = options[:language]
    country = options[:country]

    raise ArgumentError, "You need to pass a language reference" unless language
    raise ArgumentError, "You need to pass a localization key" if keys.empty?
    unless MerbBabel::exist?(language)
      language = Merb::Plugins.config[:merb_babel][:default_language]
    end
    raise ArgumentError,
      "language: #{language} not found" unless MerbBabel.exist?(language)
    
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
    MerbBabel.lookup(language, *keys) rescue nil
  end
  
  def self.lookup_with_full_locale(keys, language, country)
    if MerbBabel.exist?(language)
      MerbBabel.exist?(language, country) ?
        (MerbBabel.lookup(language, country, *keys) rescue nil) : nil
    else
      nil
    end
  end
end
