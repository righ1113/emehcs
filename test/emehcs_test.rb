# frozen_string_literal: true

# ・実行方法
# $ cd emehcs
# $ ruby test/emehcs_test.rb

require 'minitest/autorun'
require './app/emehcs'

class EmehcsTest < Minitest::Test
  def test_case
    code1  = [1, 2, '+']
    code2  = [[3, 7, '+'], 1, '+']
    code3  = [2, [3, 7, '+'], '+']
    code4  = [99, '=x', 'x']
    code5  = [['=x', [1, 8, '+']], '>fact', 4, 'fact']
    code6  = [['=x', 'x'], '>id', 4, 'id']
    code7  = [['=x', [1, 'x', '+']], '>fact', 4, 'fact']
    code8  = [['=x', [[['x', 1, '-'], 'fact'], 'x', '*'], 1, 'true'], '>fact', 4, 'fact']
    code9  = [['=x', [[['x', 1, '-'], 'fact'], 'x', '*'], 1, ['x', 1, '<']], '>fact', 4, 'fact']
    code10 = [5, 'fact']
    code11 = [[1, 2, 3, :q], 'id']
    code12 = [[1, 2, 3, :q], '=dat', 'dat', 'id']
    # 再帰のときに、後の引数の計算(左)で、先の引数を使ってはいけない
    code13 = [['=out', '=x',
               [[['x', '3x+1'], ['out', 'x', 'cons'], 'collatz'],
                [['x', 'x/2'],  ['out', 'x', 'cons'], 'collatz'],
                ['x', 'even?']], '>sub', 'sub', 'out', ['x', 2, '<']],
              '>collatz', 5, [:q], 'collatz']
    code14 = [['=out', '=x', '=stop',
               [['stop', ['x', 1, '+'], ['out', 'x', 'cons'], 'fizz'],
                ['stop', ['x', 1, '+'], ['out', 'fizz:q', 'cons'], 'fizz'],
                ['x', '0mod3?']], 'out', ['stop', 'x', '<']],
              '>fizz', 30, 1, [:q], 'fizz']

    emehcs = Emehcs.new
    assert_equal 3,   (emehcs.parse_run [], code1)
    assert_equal 11,  (emehcs.parse_run [], code2)
    assert_equal 12,  (emehcs.parse_run [], code3)
    assert_equal 99,  (emehcs.parse_run [], code4)
    assert_equal 9,   (emehcs.parse_run [], code5)
    assert_equal 4,   (emehcs.parse_run [], code6)
    assert_equal 5,   (emehcs.parse_run [], code7)
    assert_equal 1,   (emehcs.parse_run [], code8)
    assert_equal 24,  (emehcs.parse_run [], code9)
    assert_equal 120, (emehcs.parse_run [], code10)

    # emehcs.reset_env
    # assert_equal 120, (emehcs.parse_run [], code10)

    assert_equal [1, 2, 3, :q],        (emehcs.parse_run [], code11)
    assert_equal [1, 2, 3, :q],        (emehcs.parse_run [], code12)
    assert_equal [2, 4, 8, 16, 5, :q], (emehcs.parse_run [], code13)
    assert_equal ['fizz:q', 29, 28, 'fizz:q', 26, 25, 'fizz:q', 23, 22, 'fizz:q', 20, 19,
                  'fizz:q', 17, 16, 'fizz:q', 14, 13, 'fizz:q', 11, 10, 'fizz:q', 8, 7, 'fizz:q', 5, 4, 'fizz:q', 2, 1, :q],
                 (emehcs.parse_run [], code14)
  end
end
