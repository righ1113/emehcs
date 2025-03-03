# frozen_string_literal: true

# ・実行方法
# $ cd emehcs
# $ ruby test/emehcs_test_b.rb

require 'minitest/autorun'
require './app/emehcs_b'

class EmehcsTestB < Minitest::Test
  def test_case1
    emehcs = EmehcsB.new
    code1  = [1, 2, '+']
    code2  = [[3, 7, '+'], 1, '+']
    code3  = [2, [3, 7, '+'], '+']
    code4  = [99, '=x', 'x']
    code5  = [['=x', [1, 8, '+']], '>fact', 4, 'fact']
    code6  = [['=x', 'x'], '>id', 4, 'id']
    code7  = [['=x', [1, 'x', '+']], '>fact', 4, 'fact']
    code8  = [['=x', [[['x', 1, '-'], 'fact'], 'x', '*'], 1, 'true', '?'], '>fact', 4, 'fact']
    code9  = [['=x', [[['x', 1, '-'], 'fact'], 'x', '*'], 1, ['x', 1, '<'], '?'], '>fact', 4, 'fact']
    code10 = [5, 'fact']
    code11 = [[1, 2, 3, :q], 'id']
    code12 = [[1, 2, 3, :q], '=dat', 'dat', 'id']

    assert_equal 3,                    (emehcs.parse_run code1)
    assert_equal 11,                   (emehcs.parse_run code2)
    assert_equal 12,                   (emehcs.parse_run code3)
    assert_equal 99,                   (emehcs.parse_run code4)
    assert_equal 9,                    (emehcs.parse_run code5)
    assert_equal 4,                    (emehcs.parse_run code6)
    assert_equal 5,                    (emehcs.parse_run code7)
    assert_equal 1,                    (emehcs.parse_run code8)
    assert_equal 24,                   (emehcs.parse_run code9)
    assert_equal 120,                  (emehcs.parse_run code10)
    assert_equal [1, 2, 3, :q],        (emehcs.parse_run code11)
    assert_equal [1, 2, 3, :q],        (emehcs.parse_run code12)
  end

  def test_case2
    emehcs = EmehcsB.new
    code22 = '[] [3] =='
    code24 = '(>f >g (=x x g) f) >>>> 5 (5 +) (2 *) >>>'
    code25 = '((4 3 false ?) 2 false ?) 1 false ?'
    code26 = '(>f >g (=x x g) f) >>>> 5 ((5 +) (2 *) >>>) (3 -) >>>'
    code27 = '"aaa    aaa a   a"'

    assert_equal 'false',              (emehcs.run code22)
    assert_equal '20',                 (emehcs.run code24)
    assert_equal '4',                  (emehcs.run code25)
    assert_equal '17',                 (emehcs.run code26)
    assert_equal '"aaa    aaa a   a"', (emehcs.run code27)
  end

  def test_case3
    emehcs = EmehcsB.new
    code34 = '"abcde" 2 !!'
    code35 = '"abcde" length'
    code36 = '88 chr'
    code37 = '[1 2 3] 1 100 up_p'
    code38 = '0 99 ((3 3 ==) true &&) ?'

    assert_equal '"c"',                (emehcs.run code34)
    assert_equal '5',                  (emehcs.run code35)
    assert_equal 'X',                  (emehcs.run code36)
    assert_equal '[1 102 3]',          (emehcs.run code37)
    assert_equal '99',                 (emehcs.run code38)
  end
end
