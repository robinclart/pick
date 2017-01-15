require "pick/lexer"
require "pick/parser"
require "pick/interpreter"
require "pick/command"
require "pick/version"

module Pick
  module_function

  def resolve(argv, aliases: {})
    tokens         = lex(argv)
    tree           = parse(tokens, aliases)
    interpretation = interpret(tree)

    Command.new(**interpretation)
  end

  def lex(argv)
    Lexer.new(argv).lex
  end

  def parse(tokens, aliases: {})
    Parser.new(tokens, aliases: aliases).parse
  end

  def interpret(tree)
    Interpreter.new(tree).interpret
  end
end
