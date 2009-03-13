module MerbBabel
  LANGUAGE_CODE_KEY = 'mloc_language_code'.freeze
  COUNTRY_CODE_KEY = 'mloc_country_code'.freeze
  DEFAULT_DATE_FORMAT = {
    "less than %d second" => [
      "less than %d second", "less than %d seconds"],
    "%d minute" => ["%d minute", "%d minutes"],
    "about %d hour" => ["about %d hour", "about %d hours"],
    "%d day" => ["%d day", "%d days"],
    "about %d month" => ["about %d month", "about %d months"],
    "%d month" => ["%d month", "%d months"],
    "about %d year" => ["about %d year", "about %d years"],
    "over %d year" => ["over %d year", "over %d years"]
  }.freeze
  
  # TODO add a mutex for when we load the localizations, in case people want
  # to load the localizations at runtime

  # all localizations are saved in this class variable
  # localizations are namespaced using the language or locale they belong to
  #
  # for instance:
  #   localizations['en'][:right] => 'right'
  #   localizations['en'][:left] => 'left'
  #   localizations['en']['US'][:greeting] => 'Howdie'
  #   localizations['en']['AU'][:greeting] => "Good'ay"
  # 
  # locales, including languages and countries use string keys while
  # localization keys themselves are symbols  
  module Storage
  module_function
    def localizations
      @@localizations ||= reset_localizations!
    end
  
    # files containing localizations
    def localization_files
      @@localization_files ||= find_localization_files
    end
  
    # locations to look for localization files
    def localization_dirs
      @@localization_dirs ||=
        Merb::Plugins.config[:merb_babel][:localization_dirs].dup
    end
  
    # add a dir to look for localizations
    def add_localization_dir(dir_path)
      return localization_dirs if dir_path.empty?
      unless localization_dirs.include?(dir_path)
        localization_dirs << dir_path
        reload_localization_files! 
      end
      return localization_dirs
    end
  
    def load_localization!
      # look for localization files directly just in case new files were added
      reset_localization_files! 
      find_localization_files.each do |l_file|
        begin
          l_hash = YAML.load_file(l_file)
        rescue Exception => e
          # might raise a real error here in the future
          p e.inspect
        else
          tag = Locale::Tag.parse(File.basename(l_file).split('.')[0])
          if !l_hash.has_key?(LANGUAGE_CODE_KEY) && tag.language
            l_hash[LANGUAGE_CODE_KEY] = tag.language
          end
          if !l_hash.has_key?(COUNTRY_CODE_KEY) && tag.country
            l_hash[COUNTRY_CODE_KEY] = tag.country
          end
          load_localization_hash(l_hash)
        end
      end
    end
  
    # go through the localization dirs and find the localization files
    def find_localization_files
      l_files = []
      localization_dirs.map do |l_dir|
        Dir["#{l_dir}/*"].each do |file|
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
      reset_localization_dirs!
      reset_localization_files!
    end
  
    def reset_localization_dirs!
      @@localization_dirs = nil
    end
  
    def reset_localization_files!
      @@localization_files = nil
      find_localization_files
    end

    def reset_localizations!
      language = Merb::Plugins.config[:merb_babel][:default_language].to_s
      @@localizations = {language => {"DateFormat" => DEFAULT_DATE_FORMAT.dup}}
    end
  
    def reload_localization_files!
      reset_localization_files!
      find_localization_files
    end
  
    class << self
    private
      def load_localization_hash(l_hash)
        if l_hash.has_key?(LANGUAGE_CODE_KEY)
          language = l_hash[LANGUAGE_CODE_KEY]
          if l_hash.has_key?(COUNTRY_CODE_KEY)
            country = l_hash[COUNTRY_CODE_KEY]
            # load localization under the full locale namespace
            localizations[language] ||= {}
            merge_localization_hash(
              localizations[language][country] ||= {}, l_hash)
          else
            # load generic language localization
            merge_localization_hash(localizations[language] ||= {}, l_hash)
          end
        end
      end

      def merge_localization_hash(hash, l_hash)
        l_hash.keys.each do |key|
          case value = hash[key]
          when Hash
            case l_value = l_hash[key]
            when Hash
              merge_localization_hash(hash[key], l_value)
            else hash[key] = l_value
            end
          else hash[key] = l_hash[key]
          end
        end
        hash
      end
    end
  end

  def self.localizations
    Storage::localizations
  end
end
