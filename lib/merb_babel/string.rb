module MerbBabel
  class String < ::String
    def %(args)
      if args.kind_of?(Hash)
        ret = dup
        args.each{|key, value| ret.gsub!(/\%\{#{key}\}/, value.to_s)}
        ret
      else
        super
      end
    end
  end
end
