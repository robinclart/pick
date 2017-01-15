require "time"
require "date"
require "pathname"
require "uri"

module Pick
  class Interpreter
    UnknownNode = Class.new(StandardError)

    def initialize(tree)
      @tree = tree
    end

    def interpret
      interpret_node(nil, @tree)
    end

    private

    def insert_nodes_in_command(command, nodes)
      nodes.each do |node|
        result = interpret_node(command, node)
        next if !result

        case result
        when Hash
          command[:opts].merge!(result)
        when :env
          next
        else
          command[:args] << result
        end
      end

      command
    end

    def interpret_node(parent, node)
      case node.first
      when :command
        insert_nodes_in_command({ args: [], opts: {} }, node.last)
      when :option
        key   = interpret_node(nil, node.last.first)
        value = interpret_node(nil, node.last.last)

        { key.sub(/^-+/, "") => value }
      when :env
        key   = interpret_node(nil, node.last.first)
        value = interpret_node(nil, node.last.last)

        ENV[key] = value.to_s
        :env
      when :integer
        Integer(node.last)
      when :float
        Float(node.last)
      when :string
        String(node.last)
      when :milliseconds
        Float(node.last) / 1000
      when :seconds
        Integer(node.last)
      when :minutes
        Integer(node.last) * 60
      when :hours
        Integer(node.last) * 60 * 60
      when :days
        Integer(node.last) * 60 * 60 * 24
      when :bytes
        Integer(node.last)
      when :kilobytes
        Integer(node.last) * 1000
      when :megabytes
        Integer(node.last) * (1000 ** 2)
      when :gigabytes
        Integer(node.last) * (1000 ** 3)
      when :terabytes
        Integer(node.last) * (1000 ** 4)
      when :petabytes
        Integer(node.last) * (1000 ** 5)
      when :date
        Date.parse(node.last)
      when :time
        Time.parse(node.last)
      when :path
        begin
          Pathname.new(node.last)
        rescue
          String(node.last)
        end
      when :uri
        begin
          URI.parse(node.last)
        rescue
          String(node.last)
        end
      when :boolean
        node.last == "yes"
      when :keyword
        case node.last
        when "now"
          Time.now.utc
        when "yesterday"
          Date.today - 1
        when "today"
          Date.today
        when "tomorrow"
          Date.today + 1
        end
      else
        raise UnknownNode, "Unknown node: #{node.inspect}"
      end
    end
  end
end
