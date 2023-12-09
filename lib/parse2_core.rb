# frozen_string_literal: true

# Parse2Core モジュールにしてみる
module Parse2Core
  private

  def parse2_core(str) =
    parse2_sub str.gsub(/;.*/, '').gsub('[', '(').gsub(']', ':q)').gsub('(', '( ').gsub(')', ' )').split(' '), []

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
        elsif x == ':q'
          parse2_sub xs, acc + [:q] # 配列のしるし
        else
          parse2_sub xs, acc + [x]
        end
      end
    end
  end
end
