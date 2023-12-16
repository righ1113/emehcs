# frozen_string_literal: true

# Parse2Core モジュールにしてみる
module Parse2Core
  private

  def parse2_core(str)
    str2 =  str
            .gsub(/;.*/, '')
            .gsub('[', '(').gsub(']', ' :q)')
            .gsub('(', '( ').gsub(')', ' )')
            .gsub(/\A/, ' ').gsub(/\z/, ' ')
            .gsub('""', ':s')
    str3 = str2
    str2.scan(/ (?<x>".+?") /).each do |expr|
      str3 = str3.gsub(expr[0], "#{expr[0].gsub('"', '').gsub(' ', '%')}:s")
    end
    parse2_sub str3.split(' '), []
  end

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
          parse2_sub xs, acc + [:q]     # 配列のしるし
        else
          parse2_sub xs, acc + [x]
        end
      end
    end
  end
end
