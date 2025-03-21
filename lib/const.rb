# frozen_string_literal: true

# Const モジュール
module Const
  READLINE_HIST_FILE = './data/.readline_history'
  PRELUDE_FILE       = './data/prelude.eme'
  EMEHCS_VERSION     = 'emehcs version 0.2.0'
  EMEHCS_FUNC_TABLE  = {
    '+'      => :plus,
    '-'      => :minus,
    '*'      => :mul,
    '/'      => :div,
    'mod'    => :mod,
    '<'      => :lt,
    '=='     => :eq,
    '!='     => :ne,
    'true'   => :my_true,
    'false'  => :my_false,
    '&&'     => :my_and,
    'cons'   => :cons,
    's.++'   => :s_append,
    'sample' => :my_sample,
    'error'  => :error,
    'car'    => :car,
    'cdr'    => :cdr,
    # 'timer1' => :timer1,
    # 'timer2' => :timer2,
    'cmd'    => :cmd,
    # 'list'   => :list は直接呼び出す
    'eval'   => :eval,
    'eq2'    => :eq2,
    '!!'     => :index,
    'length' => :length,
    'chr'    => :chr,
    'up_p'   => :up_p
  }.freeze

  ERROR_MESSAGES = {
    insufficient_args: '引数が不足しています',
    unexpected_type:   '予期しない型'
  }.freeze

  SPECIAL_STRING_SUFFIX = ':s'
  FUNCTION_DEF_PREFIX   = '>'
  VARIABLE_DEF_PREFIX   = '='
  TRUE_FALSE_VALUES     = %w[true false].freeze

  # primitive functions
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
  # def timer1    = timer 1
  # def timer2    = timer 2
  def cmd       = (y1 = common(1); system(y1[0..-3].gsub('%', ' ')); @stack.push($?))
  # 末尾の :q を除く
  def eval      = (y1 = common(1); @code_len = 0; @stack.push parse_run(y1[0..-2]))
  def eq2       = (y1, y2 = common(2); @stack.push(run_after(y2.to_s) == run_after(y1.to_s) ? 'true' : 'false'))
  def length    = (@stack.push common(1).length - 2)
  def chr       = (@stack.push common(1).chr)
  def up_p      = (y1, y2, y3 = common(3); y3[y2] += y1; @stack.push y3)
  def index     = (y1, y2 = common(2); @stack.push y2.is_a?(Array) ? y2[y1] : "#{y2[y1]}#{SPECIAL_STRING_SUFFIX}")
  def my_and    = (@stack.push common(2, 1).all? { |x| x == 'true' } ? 'true' : 'false')

  # pop_raise
  def pop_raise = (pop = @stack.pop; raise ERROR_MESSAGES[:insufficient_args] if pop.nil?; pop)

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
