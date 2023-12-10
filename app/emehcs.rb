# frozen_string_literal: true

# ・以下は1回だけおこなう
# rbenv で Ruby 3.2.2(じゃなくてもいい) を入れる
# $ gem install bundler
# $ cd emehcs
# $ bundle install --path=vendor/bundle

# ・実行方法
# $ cd emehcs
# $ bundle exec ruby app/emehcs.rb

require './lib/parse2_core'
require './lib/repl'

# EmehcsBase クラス
class EmehcsBase
  def initialize
    @env   = {}
    @stack = []
  end

  def parse_run(code) end

  private

  def common1
    y1 = @stack.pop
    y1.is_a?(Array) && y1.last != :q ? parse_run(y1) : y1
  end

  def common2
    y1 = @stack.pop
    y1_ret = y1.is_a?(Array) && y1.last != :q ? parse_run(y1) : y1
    y2 = @stack.pop
    y2_ret = y2.is_a?(Array) && y2.last != :q ? parse_run(y2) : y2
    [y1_ret, y2_ret]
  end

  def plus      = (y1, y2 = common2; @stack.push y1 + y2)
  def minus     = (y1, y2 = common2; @stack.push y2 - y1)
  def mul       = (y1, y2 = common2; @stack.push y1 * y2)
  def even      = (y1     = common1; @stack.push(y1.even? ? 'true' : 'false'))
  def div2      = (y1     = common1; @stack.push y1 / 2)
  def mul3      = (y1     = common1; @stack.push y1 * 3 + 1)
  def mod3      = (y1     = common1; @stack.push((y1 % 3).zero? ? 'true' : 'false'))
  def mod5      = (y1     = common1; @stack.push((y1 % 5).zero? ? 'true' : 'false'))
  def s_append  = (y1, y2 = common2; @stack.push y1[0..-3] + y2)
  def my_sample = (y1     = common1; @stack.push y1[0..-2].sample)
  def error     = (y1     = common1; @stack.push raise y1.to_s)
  def car       = (y1     = common1; z = y1[0..-2]; @stack.push z[0])
  def cdr       = (y1     = common1; @stack.push y1[1..])

  def lt
    y1, y2 = common2
    @stack.push(y2 < y1 ? 'true' : 'false')
  end

  def eq
    y1, y2 = common2
    @stack.push(y2 == y1 ? 'true' : 'false')
  end

  # ④ true/false でも :q チェック
  def my_true
    y1 = @stack.pop; y2 = @stack.pop # 2コ 取り出す
    raise '引数が不足しています' if y1.nil? || y2.nil?

    y1.is_a?(Array) && y1.last != :q ? @stack.push(parse_run(y1)) : @stack.push(y1)
  end

  def my_false
    y1 = @stack.pop; y2 = @stack.pop # 2コ 取り出す
    raise '引数が不足しています' if y1.nil? || y2.nil?

    y2.is_a?(Array) && y2.last != :q ? @stack.push(parse_run(y2)) : @stack.push(y2)
  end

  def cons = (y1, y2 = common2; @stack.push y2.unshift(y1);)
end

# Emehcs クラス 相互に呼び合っているから、継承しかないじゃん
class Emehcs < EmehcsBase
  include Parse2Core

  # メインルーチン
  def parse_run(code)
    case code
    in [] then @stack.pop
    in [x, *xs]
      case x
      in Integer then @stack.push x
      in String  then parse_string x, xs
      in Array   then parse_array  x, xs
      in Symbol  then # do nothing
      else raise '予期しない型'
      end
      l = @stack.last
      if l.is_a?(String) && %w[true false].include?(l) && !@stack[1..].empty?
        @stack.pop
        parse_run xs.unshift(l) # true/false が積まれたら、もう一回実行する
      else
        parse_run xs
      end
    end
  end

  def run(str_code) = (@stack = []; parse_run(parse2(str_code)))

  def reset_env = (@env = {})

  # 文字列code から 配列code へ変換
  def parse2(str) = parse2_core str

  private

  def parse_string(x, em)
    if    x == '+'      then plus
    elsif x == '-'      then minus
    elsif x == '*'      then mul
    elsif x == '<'      then lt
    elsif x == '=='     then eq
    elsif x == 'true'   then my_true
    elsif x == 'false'  then my_false
    elsif x == 'even?'  then even
    elsif x == 'x/2'    then div2
    elsif x == '3x+1'   then mul3
    elsif x == 'cons'   then cons
    elsif x == '0mod3?' then mod3
    elsif x == '0mod5?' then mod5
    elsif x == 's.++'   then s_append
    elsif x == 'sample' then my_sample
    elsif x == 'error'  then error
    elsif x == 'car'    then car
    elsif x == 'cdr'    then cdr
    elsif x[-2..] == ':s' # 純粋文字列
      @stack.push x
    elsif x[0] == '>' # 関数定義
      @env[x[1..]] = @stack.pop
    elsif x[0] == '=' # 変数定義
      pop = @stack.pop
      # p "=== #{x} #{pop} #{@env[x[1..]]}"
      # ③ 変数定義のときは、Array を展開する
      @env[x[1..]] = pop.is_a?(Array) && pop.last != :q ? parse_run(pop) : pop
    elsif @env[x].is_a?(Array)
      # p "arra: #{x} #{@arr_flg} #{em}"
      # ② name が Array を参照しているときも、code の最後かつ関数だったら実行する、でなければ実行せずに積む
      if em.empty? && @env[x].last != :q
        @stack.push parse_run @env[x]
      else
        @stack.push @env[x]
      end
    else
      # p "norm: #{x} #{@env[x]}"
      @stack.push @env[x] # ふつうの name
    end
  end

  # ① Array のとき、code の最後かつ関数だったら実行する、でなければ実行せずに積む
  def parse_array(x, em) = (em.empty? && x.last != :q ? @stack.push(parse_run(x)) : @stack.push(x))
end

emehcs = Emehcs.new
repl = Repl.new emehcs
repl.prelude
repl.repl
