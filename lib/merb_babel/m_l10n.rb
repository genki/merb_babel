module ML10n
  class << self
    # localization helper
    def localize(key, *options)
      MI18n.localize(options.merge({:locale => locale}))
    end

    def localize_time(object, format, options)
      table_for = proc do |table_name, key, default|
        keys = ["DateFormat", table_name]
        table = MI18n.lookup(options.merge(:keys => keys)) || {}
        case table
        when Hash, Array; table[key] || default
        else default
        end
      end
      format = format.to_s.dup
      format.gsub!(/%a/) do
        table_for["AbbrDayNames", object.wday, "%a"]
      end
      format.gsub!(/%A/) do
        table_for["DayNames", object.wday, "%A"]
      end
      format.gsub!(/%b/) do
        table_for["AbbrMonthNames", object.mon - 1, "%b"]
      end
      format.gsub!(/%B/) do
        table_for["MonthNames", object.mon - 1, "%B"]
      end
      format.gsub!(/%p/) do
        table_for["AmPm", object.hour < 12 ? 0 : 1, "%p"]
      end if object.respond_to?(:hour)
      format.gsub!(/%\{([a-zA-Z]\w*)\}/) do
        object.send($1) rescue $1
      end
      object.strftime(format)
    end

    def localize_ordinal(number, keys, options)
      formats = MI18n.lookup(options.merge(:keys => keys))
      formats = formats.to_a
      format = number <= 0 ? nil : formats[number - 1] || nil
      (format || formats.last) % number
    end
  end
end
