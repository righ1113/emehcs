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
require './lib/repl_b'

# EmehcsBaseB クラス
class EmehcsBaseB
  include ConstB
  def initialize = (@env = { 'true' => 'true', 'false' => 'false' }; @stack = [])

  private

  # スタックから count 個の要素を取り出して、評価する(実際に値を使用する前段階)
  def common(count = 1)
    values = Array.new(count) { @stack.pop }
    raise ERROR_MESSAGES[:insufficient_args] if values.any?(&:nil?)

    values.map! { |y| func?(y) ? parse_run(y) : y }
    count == 1 ? values.first : values # count が 1 なら最初の要素を、そうでなければ配列全体を返す
  end

  # if と &&
  def my_if(count = 3)
    values = Array.new(count) { @stack.pop }
    raise ERROR_MESSAGES[:insufficient_args] if values.any?(&:nil?)

    else_c = Delay.new { count == 3 ? parse_run([values[2]]) : @stack.push('false') }
    parse_run([values[0]]) == 'true' ? parse_run([values[1]]) : else_c.force
  end
end

# EmehcsB クラス 相互に呼び合っているから、継承しかないじゃん
class EmehcsB < EmehcsBaseB
  include Parse2Core
  def run(str_code) = (@stack = []; run_after(parse_run(parse2_core(str_code)).to_s))

  # メインルーチンの改善
  def parse_run(code)
    case code
    in [] then @stack.last
    in [x, *xs] # each_with_index 使ったら、再帰がよけい深くなった
      case x
      in Integer then @stack.push x
      in String  then parse_string x, xs.empty?
      in Array   then parse_array  x, xs.empty?
      in Symbol  then nil # do nothing
      else            raise ERROR_MESSAGES[:unexpected_type]
      end
      parse_run xs
    end
  end

  private

  def parse_string(x, em, name = x[1..], db = [x, @env[x]], b = em && func?(@env[x]),
                   co = Delay.new { ConstB.deep_copy(@env[x]) })
    # primitive関数 の実行
    db.each { |y| (em ? send(EMEHCS_FUNC_TABLE[y]) : @stack.push(y); return 1) if EMEHCS_FUNC_TABLE.key? y }

    if x[-2..] == SPECIAL_STRING_SUFFIX # 純粋文字列 :s
      @stack.push x
    elsif x[0] == FUNCTION_DEF_PREFIX   # 関数定義
      @env[name] = pop_raise
    elsif x[0] == VARIABLE_DEF_PREFIX   # (3) 変数定義のときは、Array を実行する
      pr = pop_raise; @env[name] = func?(pr) ? parse_run(pr) : pr
    elsif @env[x].is_a?(Array)          # (2) この時も code の最後かつ関数なら実行する、でなければ積む
      b ? parse_run(co.force) : @stack.push(co.force)
    else                                # 関数・変数名
      @stack.push @env[x]
    end
  end

  # (1) Array のとき、code の最後かつ関数だったら実行する、でなければ実行せずに積む
  def parse_array(x, em) = em && func?(x) ? parse_run(x) : @stack.push(x)
end

# メイン関数としたもの
if __FILE__ == $PROGRAM_NAME
  # exec({ 'RUBY_THREAD_VM_STACK_SIZE' => '1000000000' }, '/usr/bin/ruby', $0)
  emehcs = EmehcsB.new
  repl = ReplB.new emehcs
  repl.prelude
  repl.repl
end
