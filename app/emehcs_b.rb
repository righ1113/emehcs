# frozen_string_literal: true

# ・以下は1回だけおこなう
# rbenv で Ruby 3.2.2(じゃなくてもいい) を入れる
# $ gem install bundler
# $ cd emehcs
# $ bundle install --path=vendor/bundle

# ・実行方法
# $ cd emehcs
# $ bundle exec ruby app/emehcs_b.rb
# > [ctrl]+D か exit で終了

require './lib/const_b'
require './lib/parse2_core'
require './lib/repl'

# EmehcsBaseB クラス
class EmehcsBaseB
  include ConstB
  def initialize = (@env = {}; @stack = [])

  private

  # スタックから count 個の要素を取り出して、評価する(実際に値を使用する前段階)
  def common(count = 1)
    values = Array.new(count) { @stack.pop }
    raise ERROR_MESSAGES[:insufficient_args] if values.any?(&:nil?)

    values.map! { |y| y.is_a?(Array) && y.last != :q ? parse_run(y) : y }
    count == 1 ? values.first : values # count が 1 なら最初の要素を、そうでなければ配列全体を返す
  end
end

# EmehcsB クラス 相互に呼び合っているから、継承しかないじゃん
class EmehcsB < EmehcsBaseB
  include Parse2Core
  def reset_env     = (@env = {})
  def run(str_code) = (@stack = []; run_after(parse_run(parse2_core(str_code)).to_s))

  # メインルーチンの改善
  def parse_run(code)
    case code
    in [] then @stack.pop
    in [x, *xs] # each_with_index 使ったら、再帰がよけい深くなった
      case x
      in Integer then @stack.push x
      in String  then parse_string(x, xs.empty?)
      in Array   then parse_array(x, xs.empty?)
      in Symbol  then nil # do nothing
      else raise ERROR_MESSAGES[:unexpected_type]
      end
      parse_run xs
    end
  end

  private

  def parse_string(x, em, db = [x, @env[x]], tf = !(TRUE_FALSE_VALUES.include?(x) && @stack.empty?))
    db.each do |y|
      if EMEHCS_FUNC_TABLE.key? y
        em && tf ? send(EMEHCS_FUNC_TABLE[y]) : @stack.push(y); return 1 # true/false 単体時は関数として扱わない
      end
    end
    if x[-2..] == SPECIAL_STRING_SUFFIX then @stack.push x # 純粋文字列
    elsif x[0] == FUNCTION_DEF_PREFIX && x != '>>>' then (@env[x[1..]] = pop_raise; em && @stack.push(x[1..]))
    elsif x[0] == VARIABLE_DEF_PREFIX # 変数定義
      pop = pop_raise
      # (3) 変数定義のときは、Array を実行する
      @env[x[1..]] = pop.is_a?(Array) && pop.last != :q ? parse_run(pop) : pop
      em && @stack.push(x[1..]) # REPL に変数名を出力する
    elsif @env[x].is_a?(Array)
      # (2) name が Array を参照しているときも、code の最後かつ関数だったら実行する、でなければ実行せずに積む
      b = em && @env[x].last != :q
      b ? (@stack.push parse_run ConstB.deep_copy(@env[x])) : @stack.push(ConstB.deep_copy(@env[x]))
    else
      @stack.push @env[x] # ふつうの name
    end
  end

  # (1) Array のとき、code の最後かつ関数だったら実行する、でなければ実行せずに積む
  def parse_array(x, em) = (em && x.last != :q ? @stack.push(parse_run(x)) : @stack.push(x))
end

# メイン関数としたもの
if __FILE__ == $PROGRAM_NAME
  # exec({ 'RUBY_THREAD_VM_STACK_SIZE' => '1000000000' }, '/usr/bin/ruby', $0)
  p 'ahaha'
  # emehcs = EmehcsB.new
  # repl = Repl.new emehcs
  # repl.prelude
  # repl.repl
end
