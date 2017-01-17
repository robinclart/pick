module Pick
  class Parser
    UnexpectedToken = Class.new(StandardError)

    def initialize(tokens, aliases: {})
      @tokens  = [[:start_command, nil], *tokens, [:end_command, nil]]
      @aliases = aliases
    end

    def parse
      t = consume

      parse_command if type?(t, :start_command)
    end

    private

    def parse_command
      children = []

      loop do
        t = consume

        if type?(t, :end_command)
          break
        elsif type?(t, :start_list)
          children << parse_list
          next
        elsif type?(t, :option)
          children << parse_option(t)
          next
        elsif type?(t, :env)
          children << parse_env(t)
          next
        elsif type?(t, :bytes)
          children << bytes(t.last)
          next
        elsif type?(t, :duration)
          children << duration(t.last)
          next
        elsif simple_value?(t)
          children << t.clone
          next
        else
          raise UnexpectedToken, "Unexpected token: #{t.inspect}"
        end
      end

      [:command, children]
    end

    def parse_list
      children = []

      loop do
        t = consume

        if type?(t, :end_list)
          break
        elsif type?(t, :start_list)
          children << parse_list
          next
        elsif type?(t, :bytes)
          children << bytes(t.last)
          next
        elsif type?(t, :duration)
          children << duration(t.last)
          next
        elsif simple_value?(t)
          children << t.clone
          next
        else
          raise UnexpectedToken, "Unexpected token: #{t.inspect}"
        end
      end

      [:list, children]
    end

    def parse_list_delimiter
      t = peek

      if type?(t, :list_delimiter)
        consume
        return
      elsif type?(t, :end_list)
        return
      else
        raise UnexpectedToken, "Unexpected token: #{t.inspect}"
      end
    end

    def parse_option(o)
      t     = peek
      name  = @aliases[o.last] || o.last
      value = nil

      if type?(t, :assign)
        consume
        value = parse_value
      elsif o.last.start_with?("--no-")
        name = name.gsub(/^--no-/, "--")
        value = [:boolean, "no"]
      else
        value = [:boolean, "yes"]
      end

      [:option, [[:string, name], value]]
    end

    def parse_env(e)
      t     = peek
      name  = e.last
      value = nil

      if type?(t, :assign)
        consume
        value = parse_value
      else
        raise UnexpectedToken, "Unexpected token: #{t.inspect}"
      end

      [:env, [[:string, name], value]]
    end

    def parse_value
      t = consume

      if simple_value?(t)
        t.clone
      elsif type?(t, :start_list)
        parse_list
      elsif type?(t, :bytes)
        bytes(t.last)
      elsif type?(t, :duration)
        duration(t.last)
      else
        raise UnexpectedToken, "Unexpected token: #{t.inspect}"
      end
    end

    def bytes(value)
      case value
      when /[0-9_]+B/  then [:bytes,     value.chomp("B")]
      when /[0-9_]+kB/ then [:kilobytes, value.chomp("kB")]
      when /[0-9_]+MB/ then [:megabytes, value.chomp("MB")]
      when /[0-9_]+GB/ then [:gigabytes, value.chomp("GB")]
      when /[0-9_]+TB/ then [:terabytes, value.chomp("TB")]
      when /[0-9_]+PB/ then [:petabytes, value.chomp("PB")]
      end
    end

    def duration(value)
      case value
      when /[0-9_]+ms/ then [:milliseconds, value.chomp("ms")]
      when /[0-9_]+s/  then [:seconds,      value.chomp("s")]
      when /[0-9_]+m/  then [:minutes,      value.chomp("m")]
      when /[0-9_]+h/  then [:hours,        value.chomp("h")]
      when /[0-9_]+d/  then [:days,         value.chomp("d")]
      end
    end

    def simple_value?(t)
      type?(t, :boolean)   ||
        type?(t, :keyword) ||
        type?(t, :string)  ||
        type?(t, :float)   ||
        type?(t, :integer) ||
        type?(t, :date)    ||
        type?(t, :time)    ||
        type?(t, :uri)     ||
        type?(t, :path)
    end

    def type?(x, type)
      return false unless x
      x.first == type
    end

    def peek
      @tokens.first
    end

    def consume
      @tokens.shift
    end
  end
end
