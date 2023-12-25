# frozen_string_literal: true

# Const モジュール
module Const
  READLINE_HIST_FILE = './data/.readline_history'
  PRELUDE_FILE       = './data/prelude.eme'
  EMEHCS_VERSION     = 'emehcs version 0.0.1'
  EMEHCS_FUNC_TABLE  = {
    '+'      => :plus,
    '-'      => :minus,
    '*'      => :mul,
    '<'      => :lt,
    '=='     => :eq,
    'true'   => :my_true,
    'false'  => :my_false,
    'even?'  => :even,
    'x/2'    => :div2,
    '3x+1'   => :mul3,
    'cons'   => :cons,
    '0mod3?' => :mod3,
    '0mod5?' => :mod5,
    's.++'   => :s_append,
    'sample' => :my_sample,
    'error'  => :error,
    'car'    => :car,
    'cdr'    => :cdr,
    'timer1' => :timer1,
    'timer2' => :timer2,
    'cmd'    => :cmd
  }.freeze

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
