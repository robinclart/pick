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

      # option

      if m = arg.match(/^--[a-zA-Z0-9-]+$/)
        @tokens << [:option, arg]
        return
      end

      # option with value

      if m = arg.match(/^(--[a-zA-Z0-9-]+)=(.+)?$/)
        @tokens << [:option, m[1]]
        @tokens << [:assign, "="]
        lexarg(m[2])
        return
      end

      # flag

      if m = arg.match(/^-[a-zA-Z]$/)
        @tokens << [:option, arg]
        return
      end

      # flag with value

      if m = arg.match(/^(-[a-zA-Z])(.+)$/)
        @tokens << [:option, m[1]]
        @tokens << [:assign, ""]
        lexarg(m[2])
        return
      end

      # list

      if arg == "["
        @tokens << [:start_list, "["]
        return
      end

      if arg == "]"
        @tokens << [:end_list, "]"]
        return
      end

      if m = arg.match(/^\[(.+)$/)
        lexarg("[")
        m[1].split(" ").compact.map do |a|
          lexarg(a.strip)
        end
        return
      end

      if m = arg.match(/^(.+)\]$/)
        m[1].split(" ").compact.map do |a|
          lexarg(a.strip)
        end
        lexarg("]")
        return
      end

      # env

      if m = arg.match(/^([A-Z_]+)=(.+)?$/)
        @tokens << [:env, m[1]]
        @tokens << [:assign, "="]
        lexarg(m[2])
        return
      end

      # uri

      if m = arg.match(/^[a-z]+\:\/\/(.+)$/)
        @tokens << [:uri, arg]
        return
      end

      # path

      if m = arg.match(/\//)
        @tokens << [:path, arg]
        return
      end

      # boolean

      if m = arg.match(/^(yes|no)$/)
        @tokens << [:boolean, arg]
        return
      end

      # integer

      if m = arg.match(/^-?\d+$/)
        @tokens << [:integer, arg]
        return
      end

      # float

      if m = arg.match(/^-?\d+\.\d+$/)
        @tokens << [:float, arg]
        return
      end

      # bytes

      if m = arg.match(/^-?[0-9_]+(B|kB|MB|GB|TB|PB)$/)
        @tokens << [:bytes, arg]
        return
      end

      # duration

      if m = arg.match(/^-?[0-9_]+(ms|s|m|h|d)$/)
        @tokens << [:duration, arg]
        return
      end

      # date

      if m = arg.match(/^\d{4}-\d{2}-\d{2}$/)
        @tokens << [:date, arg]
        return
      end

      # time

      if m = arg.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/)
        @tokens << [:time, arg]
        return
      end

      # keyword

      if m = arg.match(/^\@(today|tomorrow|yesterday|now)$/)
        @tokens << [:keyword, arg]
        return
      end

      @tokens << [:string, arg]

      nil
    end
  end
end
