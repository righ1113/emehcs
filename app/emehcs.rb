# frozen_string_literal: true

# ・以下は1回だけおこなう
# rbenv で Ruby 3.2.2(じゃなくてもいい) を入れる
# $ gem install bundler
# $ cd emehcs
# $ bundle install --path=vendor/bundle

# ・実行方法
# $ cd emehcs
# $ bundle exec ruby app/emehcs.rb

# EmehcsBase クラス
class EmehcsBase
  def initialize
    @env = {}
  end

  def parse_run(stack, code) end

  private

  def common1(stack)
    y1 = stack.pop
    y1_ret = y1.is_a?(Array) ? parse_run(stack, y1) : y1
    [stack, y1_ret]
  end

  def common2(stack)
    y1 = stack.pop
    y1_ret = y1.is_a?(Array) ? parse_run(stack, y1) : y1
    y2 = stack.pop
    y2_ret = y2.is_a?(Array) ? parse_run(stack, y2) : y2
    [stack, y1_ret, y2_ret]
  end

  def plus(stack)  = (stack2, y1, y2 = common2 stack; stack2.push y1 + y2; stack2)
  def minus(stack) = (stack2, y1, y2 = common2 stack; stack2.push y2 - y1; stack2)
  def mul(stack)   = (stack2, y1, y2 = common2 stack; stack2.push y1 * y2; stack2)
  def even(stack)  = (stack2, y1     = common1 stack; stack2.push(y1.even? ? 'true' : 'false'); stack2)
  def div2(stack)  = (stack2, y1     = common1 stack; stack2.push y1 / 2;  stack2)
  def mul3(stack)  = (stack2, y1     = common1 stack; stack2.push y1 * 3 + 1; stack2)
  def mod3(stack)  = (stack2, y1     = common1 stack; stack2.push((y1 % 3).zero? ? 'true' : 'false'); stack2)

  def lt(stack)
    stack2, y1, y2 = common2 stack
    stack2.push(y2 < y1 ? 'true' : 'false')
    stack2
  end

  # ④ true/false でも :q チェック
  def my_true(stack)
    y1 = stack.pop; y2 = stack.pop # 2コ 取り出す
    y1.is_a?(Array) && y1.last != :q ? stack.push(parse_run(stack, y1)) : stack.push(y1)
    stack
  end

  def my_false(stack)
    y1 = stack.pop; y2 = stack.pop # 2コ 取り出す
    y2.is_a?(Array) && y2.last != :q ? stack.push(parse_run(stack, y2)) : stack.push(y2)
    stack
  end

  def cons(stack)
    y1 = stack.pop; y2 = stack.pop # 2コ 取り出す
    stack.push y2.unshift(y1)
    stack
  end
end

# Emehcs クラス 相互に呼び合っているから、継承しかないじゃん
class Emehcs < EmehcsBase
  # メインルーチン
  def parse_run(stack, code)
    case code
    in [] then stack.pop
    in [x, *xs]
      case x
      in Integer then stack2 = stack.push x
      in String  then stack2 = parse_string stack, x, xs
      in Array   then stack2 = parse_array  stack, x, xs
      in Symbol  then stack2 = stack
      else raise '予期しない型'
      end
      l = stack2.last
      if l.is_a?(String) && %w[true false].include?(l)
        stack2.pop
        parse_run stack2, xs.unshift(l) # true/false が積まれたら、もう一回実行する
      else
        parse_run stack2, xs
      end
    end
  end

  def reset_env = (@env = {})

  # 文字列code から 配列code へ変換
  def parse2(str) = parse2_sub str.gsub('(', '( ').gsub(')', ' )').split(' '), []

  private

  def parse_string(stack, x, em)
    if    x == '+'      then stack = plus stack
    elsif x == '-'      then stack = minus stack
    elsif x == '*'      then stack = mul stack
    elsif x == '<'      then stack = lt stack
    elsif x == 'true'   then stack = my_true stack
    elsif x == 'false'  then stack = my_false stack
    elsif x == 'even?'  then (p 'even'; stack = even stack)
    elsif x == 'x/2'    then (p 'div2'; stack = div2 stack)
    elsif x == '3x+1'   then (p '3x+1'; stack = mul3 stack)
    elsif x == 'cons'   then (p 'cons'; stack = cons stack)
    elsif x == '0mod3?' then (p 'mod3'; stack = mod3 stack)
    elsif x[-2..] == ':q' # 純粋文字列
      stack.push x
    elsif x[0] == '>' # 関数定義
      @env[x[1..]] = stack.pop
    elsif x[0] == '=' # 変数定義
      pop = stack.pop
      # p "=== #{x} #{pop} #{@env[x[1..]]}"
      # ③ 変数定義のときは、Array を展開する
      @env[x[1..]] = pop.is_a?(Array) && pop.last != :q ? parse_run(stack, pop) : pop
    elsif @env[x].is_a?(Array)
      # p "arra: #{x} #{@arr_flg} #{em}"
      # ② name が Array を参照しているときも、code の最後かつ関数だったら実行する、でなければ実行せずに積む
      if em.empty? && @env[x].last != :q
        stack.push parse_run stack, @env[x]
      else
        stack.push @env[x]
      end
    else
      # p "norm: #{x} #{@env[x]}"
      stack.push @env[x] # ふつうの name
    end
    stack
  end

  # ① Array のとき、code の最後かつ関数だったら実行する、でなければ実行せずに積む
  def parse_array(stack, x, em) =
    (em.empty? && x.last != :q ? stack.push(parse_run(stack, x)) : (stack.push(x); stack))

  # 文字列code から 配列code へ変換
  def parse2_sub(data, acc)
    case data
    in [] then acc
    in [x, *xs]
      case x
      in '(' then xs2, acc2 = parse2_sub(xs, []); parse2_sub(xs2, acc + [acc2])
      in ')' then [xs, acc]
      else
        if /\A[-+]?\d+\z/ =~ x
          parse2_sub xs, acc + [x.to_i] # 数値
        else
          parse2_sub xs, acc + [x]
        end
      end
    end
  end
end

# code14 = [['=out', '=x', '=stop',
#            [['stop', ['x', 1, '+'], ['out', 'x', 'cons'], 'fizz'],
#             ['stop', ['x', 1, '+'], ['out', 'fizz:q', 'cons'], 'fizz'],
#             ['x', '0mod3?']], 'out', ['stop', 'x', '<']],
#           '>fizz', 30, 1, [:q], 'fizz']
# emehcs = Emehcs.new
# p emehcs.parse_run [], code14

emehcs = Emehcs.new
p emehcs.parse_run [], (emehcs.parse2 '((=x x) >id (=x x) >id2 66 id)')
