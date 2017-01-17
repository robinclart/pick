require "test_helper"

class LexerTest < Minitest::Test
  def test_that_we_can_initializer_a_lexer
    assert Pick::Lexer.new([])
  end

  def test_that_we_can_lex_an_empty_array
    assert_equal [], Pick.lex([])
  end

  def test_that_we_can_lex_a_string_made_of_a_single_word
    assert_equal [[:string, "hello"]], Pick.lex(["hello"])
  end

  def test_that_we_can_lex_a_string_made_of_more_words
    assert_equal [[:string, "hello world"]], Pick.lex(["hello world"])
  end

  def test_that_we_can_lex_more_than_one_string
    assert_equal [
      [:string, "hello"],
      [:string, "world"]
    ], Pick.lex(%w(hello world))
  end

  def test_that_we_can_lex_a_one_digit_integer
    assert_equal [[:integer, "1"]], Pick.lex(["1"])
  end

  def test_that_we_can_lex_a_multi_digits_integer
    assert_equal [[:integer, "1234567890"]], Pick.lex(["1234567890"])
  end

  def test_that_we_can_lex_an_empty_list
    assert_equal [
      [:start_list, "["],
      [:end_list, "]"]
    ], Pick.lex(["[]"])
  end
end
