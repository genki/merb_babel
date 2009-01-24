module MerbBabel
  class Time < ::Time
    def self.new(time, context = {})
      time = at(time)
    ensure
      time.instance_variable_set(:@context, context)
    end

    def lost_in_words(*args)
      options = args.last.kind_of?(Hash) ? args.pop : {}
      to_time = args[0] || Time.now.utc
      include_seconds = options[:include_seconds] || false
      locale = options[:locale] || nil
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - self).abs)/60).round
      distance_in_seconds = ((to_time - self).abs).round
    
      case distance_in_minutes
        when 0..1
          return (distance_in_minutes == 0) ?
            t('less than a minute') : t('%d minute', 1) unless include_seconds
          case distance_in_seconds
            when 0..4; t('less than %d second', 5)
            when 5..9; t('less than %d second', 10)
            when 10..19; t('less than %d second', 20)
            when 20..39; t('half a minute')
            when 40..59; t('less than a minute')
            else t('%d minute', 1)
          end
        when 2..44; t("%d minute", distance_in_minutes)
        when 45..89; t('about %d hour', 1)
        when 90..1439; t("about %d hour", (distance_in_minutes.to_f/60).round)
        when 1440..2879; t('%d day', 1)
        when 2880..43199; t("%d day", (distance_in_minutes/1440).round)
        when 43200..86399; t('about %d month', 1)
        when 86400..525599; t("%d month", (distance_in_minutes/43200).round)
        when 525600..1051199; t('about %d year', 1)
        else t("over %d year", (distance_in_minutes/525600).round)
      end
    end

    alias_method :ago_in_words, :lost_in_words

  private
    def t(*args)
      @context.t("DateFormat", *args)
    end
  end
end
