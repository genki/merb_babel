module ML10n
  
  class << self
  
    # TODO add a mutex for when we load the localizations, in case people want to load the localizations
    # at runtime

    # all localizations are saved in this class variable
    # localizations are namespaced using the language or locale they belong to
    #
    # for instance:
    #   ML10n.localizations['en'][:right] => 'right'
    #   ML10n.localizations['en'][:left] => 'left'
    #   ML10n.localizations['en']['US'][:greeting] => 'Howdie'
    #   ML10n.localizations['en']['AU'][:greeting] => "Good'ay"
    # 
    # locales, including languages and countries use string keys while localization keys themselves are symbols  
    def localizations
      @@localizations ||= {}
    end
  
    # files containing localizations
    def localization_files
      @@localization_files ||= ML10n.find_localization_files
    end
  
    # locations to look for localization files
    def localization_dirs
      @@localization_dirs ||= Merb::Plugins.config[:merb_babel][:localization_dirs].dup
    end
  
    # add a dir to look for localizations
    def add_localization_dir(dir_path)
      return ML10n.localization_dirs if dir_path.empty?
      unless ML10n.localization_dirs.include?(dir_path)
        ML10n.localization_dirs << dir_path
        ML10n.reload_localization_files! 
      end
      return ML10n.localization_dirs
    end
  
    def load_localization!
    
      # look for localization files directly just in case new files were added
      ML10n.reset_localization_files! 
      ML10n.find_localization_files.each do |l_file|
        begin
          l_hash = YAML.load_file(l_file).symbolize_keys
        rescue Exception => e
          # might raise a real error here in the future
          p e.inspect
        else
          load_localization_hash(l_hash)
        end
      end
    
    end
  
    # go through the localization dirs and find the localization files
    def find_localization_files
      l_files = []
      ML10n.localization_dirs.map do |l_dir|
        Dir["#{l_dir}/*", '*.{yml,yaml}'].each do |file|
          l_files << file unless l_files.include?(file)
        end
      end
      return l_files
    end
  
    # reset the localization dirs and files to the plugin config
    # careful when using this method since it will remove any localization files
    # you loaded after the plugin started
    # 
    # note that it won't clear the localization already loaded in memory
    def reset_localization_files_and_dirs!
      ML10n.reset_localization_dirs!
      ML10n.reset_localization_files!
    end
  
    def reset_localization_dirs!
      @@localization_dirs = nil
    end
  
    def reset_localization_files!
      @@localization_files = nil
      ML10n.find_localization_files
    end
  
    def reload_localization_files!
      ML10n.reset_localization_files!
      ML10n.find_localization_files
    end
  
    # localization helper
    def localize(key, *options)
      MI18n.localize(options.merge({:locale => locale}))
    end
  
    protected
  
    def load_localization_hash(l_hash)
      if l_hash.valid_localization_hash?
        language = l_hash[:mloc_language_code]
        if l_hash.localization_hash_with_locale?
          country = l_hash[:mloc_country_code]
          # load localization under the full locale namespace
          ML10n.localizations[language] ||= {}
          (ML10n.localizations[language][country] ||= {}).merge!(l_hash)
        else
          # load generic language localization
          (ML10n.localizations[language] ||= {}).merge!(l_hash)
        end
      end
    end
    
  end
  
end