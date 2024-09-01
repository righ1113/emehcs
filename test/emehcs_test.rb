# frozen_string_literal: true

# ・実行方法
# $ cd emehcs
# $ ruby test/emehcs_test.rb

require 'minitest/autorun'
require './app/emehcs'

class EmehcsTest < Minitest::Test
  def test_case1
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
    code13 = [
      ['=out', '=x', [
        [['x', '3x+1'], ['out', 'x', 'cons'], 'collatz'],
        [['x', 'x/2'], ['out', 'x', 'cons'], 'collatz'],
        ['x', 'even?']
      ], '>sub', 'sub', 'out', ['x', 2, '<']],
      '>collatz', 5, [:q], 'collatz'
    ]
    code14 = [
      ['=out', '=x', '=stop', [
        ['stop', ['x', 1, '+'], ['out', 'x', 'cons'], 'fizz'],
        ['stop', ['x', 1, '+'], ['out', 'fizz:s', 'cons'], 'fizz'],
        ['x', '0mod3?']
      ], 'out', ['stop', 'x', '<']],
      '>fizz', 30, 1, [:q], 'fizz'
    ]

    emehcs = Emehcs.new
    assert_equal 3,   (emehcs.parse_run code1)
    assert_equal 11,  (emehcs.parse_run code2)
    assert_equal 12,  (emehcs.parse_run code3)
    assert_equal 99,  (emehcs.parse_run code4)
    assert_equal 9,   (emehcs.parse_run code5)
    assert_equal 4,   (emehcs.parse_run code6)
    assert_equal 5,   (emehcs.parse_run code7)
    assert_equal 1,   (emehcs.parse_run code8)
    assert_equal 24,  (emehcs.parse_run code9)
    assert_equal 120, (emehcs.parse_run code10)

    # emehcs.reset_env
    # assert_equal 120, (emehcs.parse_run [], code10)

    assert_equal [1, 2, 3, :q],        (emehcs.parse_run code11)
    assert_equal [1, 2, 3, :q],        (emehcs.parse_run code12)
    # assert_equal [2, 4, 8, 16, 5, :q], (emehcs.parse_run code13)
    # assert_equal(
    #   [
    #     'fizz:s', 29, 28, 'fizz:s', 26, 25, 'fizz:s', 23, 22, 'fizz:s', 20, 19,
    #     'fizz:s', 17, 16, 'fizz:s', 14, 13, 'fizz:s', 11, 10, 'fizz:s', 8, 7, 'fizz:s', 5, 4, 'fizz:s', 2, 1, :q
    #   ],
    #   (emehcs.parse_run code14)
    # )

    assert_equal 66, emehcs.parse_run(emehcs.parse2('((=x x) >id (=x x) >id2 66 id)'))
    code16 = emehcs.parse2 <<~TEXT
      ; これはコメントです。
      (
        (=out =x (
          ((x 3x+1) (out x cons) collatz)
          ((x x/2)  (out x cons) collatz) (x even?)) (out 1 cons) (x 2 <)) >collatz
        5 [] collatz)
    TEXT
    # assert_equal [1, 2, 4, 8, 16, 5, :q], (emehcs.parse_run code16)
  end

  def test_case2
    emehcs = Emehcs.new
    code17 = '7 6 true'
    code18 = 'false 6 false'
    code19 = 'false'
    code20 = '6 true'
    e = assert_raises(RuntimeError) { emehcs.run code20 } # RuntimeErrorが発生することを検証
    code22 = '[] [3] =='
    code23 = 'x/2 (>f 7 f)'
    code24 = '(>f >g (=x x g) f) >>>> 5 (5 +) (2 *) >>>'
    code25 = '4 3 false 2 false 1 false'
    code26 = '(>f >g (=x x g) f) >>>> 5 ((5 +) (2 *) >>>) (3 -) >>>'
    code27 = '"aaa    aaa a   a"'

    assert_equal '6',                  (emehcs.run code17)
    assert_equal 'false',              (emehcs.run code18)
    assert_equal 'false',              (emehcs.run code19)
    assert_equal '引数が不足しています', e.message # エラーメッセージを検証
    assert_equal 'false',              (emehcs.run code22)
    # assert_equal '3',                  (emehcs.run code23)
    assert_equal '20',                 (emehcs.run code24)
    assert_equal '4',                  (emehcs.run code25)
    assert_equal '17',                 (emehcs.run code26)
    assert_equal '"aaa    aaa a   a"', (emehcs.run code27)
  end

  def test_case3
    emehcs = Emehcs.new
    code28 = '1 =x x (x 1 +) (x 2 +) list'

    assert_equal '[1 2 3]', (emehcs.run code28)
  end
end
