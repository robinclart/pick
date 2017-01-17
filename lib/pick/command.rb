module Pick
  class Command
    def initialize(args: [], opts: {})
      @args = args
      @opts = opts
    end

    attr_reader :args, :opts

    def respond_to_missing?(m, include_private = false)
      if m.to_s.end_with?("?") && @opts.key?(m.to_s.chomp("?"))
        true
      elsif @opts.key?(m.to_s)
        true
      else
        super
      end
    end

    def method_missing(m, *args, &block)
      if m.to_s.end_with?("?") && @opts.key?(m.to_s.chomp("?"))
        !!@opts[m.to_s.chomp("?")]
      elsif @opts.key?(m.to_s)
        @opts[m.to_s]
      else
        super
      end
    end
  end
end
