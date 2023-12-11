# frozen_string_literal: true

# Const モジュール
module Const
  READLINE_HIST_FILE = './data/.readline_history'
  PRELUDE_FILE       = './data/prelude.eme'
  EMEHCS_VERSION     = 'emehcs version 0.0.1'

  # Const クラス
  class Const
    def self.deep_copy(arr)
      Marshal.load(Marshal.dump(arr))
    end

    # このようにして assert を使うことができます
    def self.assert(cond1, cond2, message = 'Assertion failed')
      raise "#{cond1} #{cond2} <#{message}>" unless cond1 == cond2
    end
  end
end
