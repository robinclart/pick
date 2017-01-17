module Pick
  class Lexer
    def initialize(argv)
      @argv   = argv
      @tokens = []
    end

    def lex
      @argv.each do |arg|
        lexarg(arg)
      end

      @tokens
    end

    private

    def lexarg(arg)
      if arg.nil?
        @tokens << [:string, ""]
        return
      end

      if m = arg.match(%r/^([A-Z_]+)=(.+)?$/)
        @tokens << [:env, m[1]]
        @tokens << [:assign, "="]
        lexarg(m[2])
        return
      end

      if arg.match(%r/^--[a-zA-Z0-9-]+$/)
        @tokens << [:option, arg]
        return
      end

      if m = arg.match(%r/^(--[a-zA-Z0-9-]+)=(.+)?$/)
        @tokens << [:option, m[1]]
        @tokens << [:assign, "="]
        lexarg(m[2])
        return
      end

      if arg.match(%r/^-[a-zA-Z]$/)
        @tokens << [:option, arg]
        return
      end

      if m = arg.match(%r/^(-[a-zA-Z])(.+)$/)
        @tokens << [:option, m[1]]
        @tokens << [:assign, ""]
        lexarg(m[2])
        return
      end

      if arg.match(%r/^[a-z]+\:\/\/(.+)/)
        @tokens << [:uri, arg]
        return
      end

      if arg.match(%r/\//)
        @tokens << [:path, arg]
        return
      end

      if arg.match(%r/^(yes|no)$/)
        @tokens << [:boolean, arg]
        return
      end

      if arg.match(%r/^-?\d+$/)
        @tokens << [:integer, arg]
        return
      end

      if arg.match(%r/^-?\d+\.\d+$/)
        @tokens << [:float, arg]
        return
      end

      if arg.match(%r/^-?[0-9_]+(B|kB|MB|GB|TB|PB)$/)
        @tokens << [:bytes, arg]
        return
      end

      if arg.match(%r/^-?[0-9_]+(ms|s|m|h|d)$/)
        @tokens << [:duration, arg]
        return
      end

      if arg.match(%r/^\d{4}-\d{2}-\d{2}$/)
        @tokens << [:date, arg]
        return
      end

      if arg.match(%r/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/)
        @tokens << [:time, arg]
        return
      end

      if arg.match(%r/^\@(today|tomorrow|yesterday|now)$/)
        @tokens << [:keyword, arg]
        return
      end

      @tokens << [:string, arg]

      return
    end
  end
end
