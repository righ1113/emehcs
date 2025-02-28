# frozen_string_literal: true

# ・以下は1回だけおこなう
# rbenv で Ruby 3.2.2(じゃなくてもいい) を入れる
# $ gem install bundler
# $ cd emehcs
# $ bundle install --path=vendor/bundle

# ・実行方法
# $ cd emehcs
# $ bundle exec ruby app/emehcs.rb
# > [ctrl]+D か exit で終了

require 'time'
require './lib/const'
require './lib/parse2_core'
require './lib/repl'

# Primitive 関数
module Primitive
  include Const

  def plus      = (@stack.push common(2).reduce(:+))
  def minus     = (y1, y2 = common(2); @stack.push y2 - y1)
  def mul       = (@stack.push common(2).reduce(:*))
  def div       = (y1, y2 = common(2); @stack.push y2 / y1)
  def mod       = (y1, y2 = common(2); @stack.push y2 % y1)
  def lt        = (y1, y2 = common(2); @stack.push(y2 < y1 ? 'true' : 'false'))
  def eq        = (y1, y2 = common(2); @stack.push(y2 == y1 ? 'true' : 'false'))
  def ne        = (y1, y2 = common(2); @stack.push(y2 != y1 ? 'true' : 'false'))
  def s_append  = (y1, y2 = common(2); @stack.push y1[0..-3] + y2)
  def my_sample = (@stack.push common(1)[0..-2].sample)
  def error     = (@stack.push raise common(1).to_s[0..-3])
  def car       = (y1 = common(1); z = y1[0..-2]; @stack.push z[0])
  def cdr       = (@stack.push common(1)[1..])
  def cons      = (y1, y2 = common(2); @stack.push y2.unshift(y1);)
  def my_true   = my_true_false true
  def my_false  = my_true_false false
  def timer1    = timer 1
  def timer2    = timer 2
  def cmd       = (y1 = common(1); system(y1[0..-3].gsub('%', ' ')); @stack.push($?))
  # 末尾の :q を除く
  def eval      = (y1 = common(1); @code_len = 0; @stack.push parse_run(y1[0..-2]))
  def eq2       = (y1, y2 = common(2); @stack.push(run_after(y2.to_s) == run_after(y1.to_s) ? 'true' : 'false'))
  def length    = (@stack.push common(1).length - 2)
  def chr       = (@stack.push common(1).chr)
  def up_p      = (y1, y2, y3 = common(3); y3[y2] += y1; @stack.push y3)
  def index     = (y1, y2 = common(2); @stack.push y2.is_a?(Array) ? y2[y1] : "#{y2[y1]}#{SPECIAL_STRING_SUFFIX}")
end

# EmehcsBase クラス
class EmehcsBase
  include Const
  include Primitive

  def initialize = (@env = {}; @stack = []; @code_len = 0; @and_flg = false)
  # abstract_method
  def parse_run(code) = raise NotImplementedError, 'Subclasses must implement abstract_method'
  # abstract_method
  def run_after(str)  = raise NotImplementedError, 'Subclasses must implement abstract_method'

  private

  # スタックから count 個の要素を取り出して、評価する(実際に値を使用する前段階)
  def common(count = 1)
    values = Array.new(count) { @stack.pop }
    raise ERROR_MESSAGES[:insufficient_args] if values.any?(&:nil?)

    values = values.map { |y| y.is_a?(Array) && y.last != :q ? parse_run(y) : y }
    count == 1 ? values.first : values # count が 1 なら最初の要素を、そうでなければ配列全体を返す
  end

  def common2_ = (@and_flg = true; result = common(2); @and_flg = false; result)

  # (4) true/false でも :q チェック
  def my_true_false(bool)
    y1 = @stack.pop; y2 = @stack.pop # 2コ 取り出す
    raise ERROR_MESSAGES[:insufficient_args] if y1.nil? || y2.nil?

    y3 = bool ? y1 : y2
    y3.is_a?(Array) && y3.last != :q ? @stack.push(parse_run(y3)) : @stack.push(y3)
  end

  def timer(mode)
    y1 = @stack.pop; y2 = @stack.pop
    raise ERROR_MESSAGES[:insufficient_args] if y1.nil? || y2.nil?

    y1_ret = y1.is_a?(Array) && y1.last != :q ? parse_run(y1) : y1
    y1_ret = (Time.parse(y1_ret) - Time.now).to_i if mode == 2
    sleep y1_ret
    y2_ret = y2.is_a?(Array) && y2.last != :q ? parse_run(y2) : y2
    @stack.push y2_ret
  end

  def my_and
    y1, y2 = common2_
    # p "y1=#{y1}, y2=#{y2}"
    @stack.push(y1 == y2 && y1 == 'true' ? 'true' : 'false')
  end
end

# Emehcs クラス 相互に呼び合っているから、継承しかないじゃん
class Emehcs < EmehcsBase
  include Parse2Core

  # メインルーチンの改善
  def parse_run(code)
    @code_len = code.length if @code_len.zero? # コード長の初期化
    case code
    in [] then handle_empty_code
    in [x, *xs]
      case x
      in Integer then handle_integer(x)
      in String  then x == 'list' ? handle_list : parse_string(x, xs.empty?)
      in Array   then parse_array(x, xs.empty?)
      in Symbol  then nil # do nothing
      else raise ERROR_MESSAGES[:unexpected_type]
      end
      handle_true_false_condition(@stack.last, xs)
    end
  end

  def run(str_code) = (@stack = []; run_after(parse_run(parse2_core(str_code)).to_s))
  def reset_env     = (@env = {})

  private

  def handle_empty_code = (@code_len = 0; @stack.pop)
  def handle_integer(x) = @stack.push x

  def handle_list
    s = Const.deep_copy(@stack.pop(@code_len - 1))
    s.map! { |n| n.is_a?(Array) && n.last != :q ? (@stack.shift; parse_run(n)) : parse_run([n]) }
    @code_len = 0; s.push(:q); @stack.push s
  end

  def handle_true_false_condition(last, xs)
    if last.is_a?(String) && TRUE_FALSE_VALUES.include?(last) && !@stack[1..].empty? && xs.empty? && !@and_flg
      @stack.pop                 # true/false をスタックから消す
      parse_run xs.unshift(last) # true/false の関数動作
    else
      parse_run xs               # メインルーチンの再帰をここで行う
    end
  end

  def parse_string(x, em, tf = !(TRUE_FALSE_VALUES.include?(x) && @stack.empty?))
    if    EMEHCS_FUNC_TABLE.key? x
      em && tf ? send(EMEHCS_FUNC_TABLE[x])       : @stack.push(x) # true/false 単体時は関数として扱わない
    elsif EMEHCS_FUNC_TABLE.key? @env[x]
      em && tf ? send(EMEHCS_FUNC_TABLE[@env[x]]) : @stack.push(@env[x])
    elsif x[-2..] == SPECIAL_STRING_SUFFIX then @stack.push x # 純粋文字列
    elsif x[0]    == FUNCTION_DEF_PREFIX && x != '>>>' then (@env[x[1..]] = pop_raise; em && @stack.push(x[1..]))
    elsif x[0]    == VARIABLE_DEF_PREFIX # 変数定義
      pop = pop_raise
      # (3) 変数定義のときは、Array を実行する
      @env[x[1..]] = pop.is_a?(Array) && pop.last != :q ? parse_run(pop) : pop
      em && @stack.push(x[1..]) # REPL に変数名を出力する
    elsif @env[x].is_a?(Array) then parse_string_env_array x, em
    else
      @stack.push @env[x] # ふつうの name
    end
  end

  # (2) name が Array を参照しているときも、code の最後かつ関数だったら実行する、でなければ実行せずに積む
  def parse_string_env_array(x, em)
    if em && @env[x].last != :q
      @code_len = 0; @stack.push parse_run Const.deep_copy(@env[x])
    else
      @stack.push Const.deep_copy(@env[x])
    end
  end

  # (1) Array のとき、code の最後かつ関数だったら実行する、でなければ実行せずに積む
  def parse_array(x, em) = (@code_len += @stack.length; em && x.last != :q ? @stack.push(parse_run(x)) : @stack.push(x))
  # pop_raise
  def pop_raise = (pop = @stack.pop; raise ERROR_MESSAGES[:insufficient_args] if pop.nil?; pop)
end

# メイン関数としたもの
if __FILE__ == $PROGRAM_NAME
  # exec({ 'RUBY_THREAD_VM_STACK_SIZE' => '1000000000' }, '/usr/bin/ruby', $0)
  emehcs = Emehcs.new
  repl = Repl.new emehcs
  repl.prelude
  repl.repl
end
