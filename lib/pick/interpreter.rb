require "time"
require "date"
require "pathname"
require "uri"

module Pick
  class Interpreter
    UnknownNode  = Class.new(StandardError)
    InvalidValue = Class.new(StandardError)

    MILLISECONDS = (1 / 1_000.0)
    SECONDS      = 1
    MINUTES      = (60 * SECONDS)
    HOURS        = (60 * MINUTES)
    DAYS         = (24 * HOURS)

    BYTES        = 1
    KILOBYTES    = (1000**1)
    MEGABYTES    = (1000**2)
    GIGABYTES    = (1000**3)
    TERABYTES    = (1000**4)
    PETABYTES    = (1000**5)

    def initialize(tree)
      @tree = tree
    end

    def interpret
      interpret_node(@tree)
    end

    private

    def interpret_node(node)
      type  = node.first
      value = node.last

      case type
      when :command
        command({ args: [], opts: {} }, value)
      when :list
        list([], value)
      when :option
        option(value)
      when :env
        env(value)
      when :integer
        integer(value)
      when :float
        float(value)
      when :string
        string(value)
      when :milliseconds
        duration(value, MILLISECONDS)
      when :seconds
        duration(value, SECONDS)
      when :minutes
        duration(value, MINUTES)
      when :hours
        duration(value, HOURS)
      when :days
        duration(value, DAYS)
      when :bytes
        bytes(value, BYTES)
      when :kilobytes
        bytes(value, KILOBYTES)
      when :megabytes
        bytes(value, MEGABYTES)
      when :gigabytes
        bytes(value, GIGABYTES)
      when :terabytes
        bytes(value, TERABYTES)
      when :petabytes
        bytes(value, PETABYTES)
      when :date
        date(value)
      when :time
        time(value)
      when :path
        path(value)
      when :uri
        uri(value)
      when :boolean
        boolean(value)
      when :keyword
        keyword(value)
      else
        raise UnknownNode, "Unknown node: #{node.inspect}"
      end
    end

    def command(parent, nodes)
      nodes.each do |node|
        value = interpret_node(node)

        case value
        when :env
          next
        when NilClass
          next
        when Hash
          parent[:opts].merge!(value)
        else
          parent[:args] << value
        end
      end

      parent
    end

    def list(parent, nodes)
      nodes.each do |node|
        parent << interpret_node(node)
      end

      parent
    end

    def option(node)
      key   = interpret_node(node.first)
      value = interpret_node(node.last)

      { key.sub(/^-+/, "") => value }
    end

    def env(node)
      key   = interpret_node(node.first)
      value = interpret_node(node.last)

      ENV[key] = value.to_s
      :env
    end

    def integer(value)
      Integer(value)
    end

    def float(value)
      Float(value)
    end

    def string(value)
      String(value)
    end

    def duration(value, multiplier)
      integer(value) * multiplier
    end

    def bytes(value, multiplier)
      integer(value) * multiplier
    end

    def date(value)
      Date.parse(value)
    rescue
      string(value)
    end

    def time(value)
      Time.parse(value)
    rescue
      string(value)
    end

    def path(value)
      Pathname.new(value)
    rescue
      string(value)
    end

    def uri(value)
      URI.parse(value)
    rescue
      string(value)
    end

    def boolean(value)
      case value
      when "yes" then true
      when "no"  then false
      else
        raise InvalidValue, "Invalid boolean: #{value}"
      end
    end

    def keyword(value)
      case value
      when "@now"
        Time.now.utc
      when "@yesterday"
        Date.today - 1
      when "@today"
        Date.today
      when "@tomorrow"
        Date.today + 1
      else
        raise InvalidValue, "Invalid keyword: #{value}"
      end
    end
  end
end
