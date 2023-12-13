# frozen_string_literal: true

# ・以下は1回だけおこなう
# rbenv で Ruby 3.2.2(じゃなくてもいい) を入れる
# $ gem install bundler
# $ cd emehcs
# $ bundle install --path=vendor/bundle

# ・実行方法
# $ cd emehcs
# $ bundle exec ruby app/emehcs.rb

require './lib/const'
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
    raise '引数が不足しています' if y1.nil?

    y1.is_a?(Array) && y1.last != :q ? parse_run(y1) : y1
  end

  def common2
    y1 = @stack.pop; y2 = @stack.pop
    raise '引数が不足しています' if y1.nil? || y2.nil?

    y1_ret = y1.is_a?(Array) && y1.last != :q ? parse_run(y1) : y1
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

  # (4) true/false でも :q チェック
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
  include Const
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
      if l.is_a?(String) && %w[true false].include?(l) && !@stack[1..].empty? && xs.empty?
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
    if    EMEHCS_FUNC_TABLE.key? x
      if %w[true false].include?(x)
        em.empty? && !@stack.empty? ? send(EMEHCS_FUNC_TABLE[x]) : @stack.push(x)
      else
        em.empty? ? send(EMEHCS_FUNC_TABLE[x]) : @stack.push(x)             # プリミティブ関数実行1
      end
    elsif EMEHCS_FUNC_TABLE.key? @env[x]
      if %w[true false].include?(@env[x])
        em.empty? && !@stack.empty? ? send(EMEHCS_FUNC_TABLE[@env[x]]) : @stack.push(@env[x])
      else
        em.empty? ? send(EMEHCS_FUNC_TABLE[@env[x]]) : @stack.push(@env[x]) # プリミティブ関数実行2
      end
    elsif x[-2..] == ':s' # 純粋文字列
      @stack.push x
    elsif x[0] == '>' && x != '>>>' # 関数定義
      @env[x[1..]] = @stack.pop
      @stack.push x[1..] if em.empty? # REPL に関数名を出力する
    elsif x[0] == '=' # 変数定義
      pop = @stack.pop
      # (3) 変数定義のときは、Array を実行する
      @env[x[1..]] = pop.is_a?(Array) && pop.last != :q ? parse_run(pop) : pop
      @stack.push x[1..] if em.empty? # REPL に変数名を出力する
    elsif @env[x].is_a?(Array)
      # (2) name が Array を参照しているときも、code の最後かつ関数だったら実行する、でなければ実行せずに積む
      if em.empty? && @env[x].last != :q
        @stack.push parse_run Const.deep_copy(@env[x])
      else
        @stack.push           Const.deep_copy(@env[x])
      end
    else
      @stack.push @env[x] # ふつうの name
    end
  end

  # (1) Array のとき、code の最後かつ関数だったら実行する、でなければ実行せずに積む
  def parse_array(x, em) = (em.empty? && x.last != :q ? @stack.push(parse_run(x)) : @stack.push(x))
end

# メイン関数としたもの
if __FILE__ == $PROGRAM_NAME
  emehcs = Emehcs.new
  repl = Repl.new emehcs
  repl.prelude
  repl.repl
end
